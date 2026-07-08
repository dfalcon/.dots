# Time Doctor 3.12.16 — фікс скріншотів на Hyprland/Wayland

## Проблема

Time Doctor на Hyprland (Wayland) робить білі/порожні скріншоти. На i3 (X11) все працювало нормально.

**Причина:** Hyprland не пише вивід композитора у root framebuffer XWayland. TD використовує нативний аддон `screenshooter.node` (Node.js native addon), який викликає `XGetImage` через libX11. `XGetImage` на Wayland завжди повертає порожні дані — звідси білі скріни.

---

## Рішення

Замінити `node_modules/@timedoctor/node-screenshot/index.js` всередині `app.asar` на pure-JS реалізацію, яка викликає `grim` (нативний Wayland screenshotter) замість нативного аддона.

---

## Крок 1 — Розпакувати AppImage

```bash
cd ~/Downloads
./timedoctor-desktop_3.12.16_linux-x86_64.AppImage --appimage-extract
# Результат: ~/Downloads/squashfs-root/
```

Зберегти оригінальний asar:
```bash
cp ~/Downloads/squashfs-root/resources/app.asar /tmp/td-app-orig.asar
```

---

## Крок 2 — Патч app.asar

Запустити цей Node.js скрипт:

```js
const fs = require('fs');

// Новий index.js — grim-based screenshot замість screenshooter.node
// ВАЖЛИВО: має бути <= 676 байт (розмір оригінального index.js)
const code = `const{execSync:x}=require('child_process'),fs=require('fs'),o=require('os'),p=require('path');
function ss(d,f,b,b64,cb){try{const t=p.join(o.tmpdir(),'.td_'+process.pid+'_'+Date.now()+'.jpg');x('/usr/bin/grim -t jpeg -q 85 '+JSON.stringify(t),{timeout:10000});const r=fs.readFileSync(t);fs.unlinkSync(t);fs.writeFileSync(f,b64?r.toString('base64'):r);cb(null,1,f);}catch(e){cb(e,0,null);}}
const s={takeScreenshot:ss,takeScreenshotWithPromise:(d,f,b,b64)=>new Promise((r,j)=>ss(d,f,b,b64!=false,(e,c,v)=>e?j(e):r(v))),canTakeScreenshot:()=>true,getOnlineDisplayList:()=>[0]};
module.exports={screenshooter:s,setLogger:()=>{}};`;

const buf = fs.readFileSync('/tmp/td-app-orig.asar');
const headerSize = buf.readUInt32LE(12);

// КРИТИЧНО: dataStart = 16 + roundUp4(headerSize), НЕ просто 16 + headerSize
// Chromium Pickle формат вирівнює header до 4 байт
const paddedSize = headerSize + ((4 - headerSize % 4) % 4);
const dataStart = 16 + paddedSize;

const header = JSON.parse(buf.slice(16, 16 + headerSize).toString());
const idx = header.files.node_modules.files['@timedoctor'].files['node-screenshot'].files['index.js'];
const absOff = dataStart + parseInt(idx.offset);

if (code.length > idx.size) throw new Error(`code too big: ${code.length} > ${idx.size}`);

// In-place патч: заповнюємо newlines до оригінального розміру
const patch = Buffer.alloc(idx.size, 0x0a);
Buffer.from(code).copy(patch);

const out = Buffer.from(buf);
patch.copy(out, absOff);

fs.writeFileSync('/tmp/td-patched.asar', out);
console.log('done');
```

Застосувати:
```bash
node patch-td.js
cp /tmp/td-patched.asar ~/Downloads/squashfs-root/resources/app.asar
```

---

## Крок 3 — Запуск

Не запускати бінарник напряму — потрібен AppRun щоб правильно виставити `LD_LIBRARY_PATH`, `GSETTINGS_SCHEMA_DIR`, `XDG_DATA_DIRS` тощо. `DESKTOPINTEGRATION=1` пропускає інсталяцію desktop-файлів і одразу запускає бінарник. `APPDIR` потрібен бо AppRun не може auto-detect коли є аргументи типу `--no-sandbox`.

```bash
APPDIR=~/Downloads/squashfs-root \
APPIMAGE=~/Downloads/timedoctor-desktop_3.12.16_linux-x86_64.AppImage \
DESKTOPINTEGRATION=1 \
~/Downloads/squashfs-root/AppRun --no-sandbox
```

---

## Крок 4 — Autostart (Hyprland)

В `~/.config/hypr/hyprland.conf`:
```
exec-once = APPDIR=/home/dfalcon/Downloads/squashfs-root APPIMAGE=/home/dfalcon/Downloads/timedoctor-desktop_3.12.16_linux-x86_64.AppImage DESKTOPINTEGRATION=1 /home/dfalcon/Downloads/squashfs-root/AppRun --no-sandbox
```

В `~/.local/share/applications/appimagekit-timedoctor-desktop.desktop`:
```
Exec=env APPDIR=/home/dfalcon/Downloads/squashfs-root APPIMAGE=/home/dfalcon/Downloads/timedoctor-desktop_3.12.16_linux-x86_64.AppImage DESKTOPINTEGRATION=1 /home/dfalcon/Downloads/squashfs-root/AppRun --no-sandbox %U
```

---

## Підводні камені які ми знайшли

### 1. Chromium Pickle 2-байтний padding
`dataStart` в asar НЕ дорівнює `16 + headerSize`. Chromium Pickle вирівнює header до 4 байт:
```js
// НЕПРАВИЛЬНО:
const dataStart = 16 + headerSize;  // зміщення на 2 байти → корумпує сусідній файл

// ПРАВИЛЬНО:
const paddedSize = headerSize + ((4 - headerSize % 4) % 4);
const dataStart = 16 + paddedSize;
```
У нашому випадку: headerSize=222786, paddedSize=222788, dataStart=222804.

### 2. Integrity hashes в новому @electron/asar
`@electron/asar pack` додає SHA256 integrity хеші до header. Electron 7.3.3 не підтримує ці поля і крешиться. Тому потрібен in-place binary патч а не repack.

### 3. TD пише в filePath, не повертає base64 в callback
`takeScreenshot(displayId, filePath, blurRadius, base64, callback)`:
- Коли `base64=true` — пише base64-encoded JPEG у `filePath`, callback отримує `(null, 1, filePath)`
- Коли `base64=false` — пише raw JPEG у `filePath`, callback отримує `(null, 1, filePath)`

**НЕ** повертає base64 string в callback (хоча так здається логічним).

### 4. Обов'язкові методи для старту таймера
Без цих методів кнопка старту таймера не реагує:
- `canTakeScreenshot()` → `true`
- `getOnlineDisplayList()` → `[0]`

### 5. Запуск через squashfs-root без AppRun = білий екран
Без `AppRun` не виставляються `GSETTINGS_SCHEMA_DIR` та `XDG_DATA_DIRS` — GTK не може знайти теми/схеми → UI не рендериться.

### 6. APPDIR треба задавати явно
AppRun шукає APPDIR обходячи дерево директорій в пошуку файлу `$1`. З аргументом `--no-sandbox` шукає файл `--no-sandbox` і не знаходить → APPDIR=`""` → шлях до бінарника `/timedoctor-desktop` → Not Found.

---

## При оновленні TD

Якщо TD оновиться — потрібно:
1. Перевірити що `index.js` в новому asar той самий розмір (676 байт)
2. Зберегти новий оригінал: `cp .../app.asar /tmp/td-app-orig.asar`
3. Перезапустити patch скрипт
4. Якщо розмір змінився — підправити код щоб влазив (або знайти новий файл для патчу)
