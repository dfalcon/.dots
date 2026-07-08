# i3 → Hyprland міграція

## Файли конфігу

| Файл | Призначення |
|------|-------------|
| `~/.config/hypr/hyprland.conf` | Головний конфіг |
| `~/.config/hypr/wallpaper.sh` | Рандомна шпалера з `~/Pictures/Wallpapers/cyberpunk/` |
| `~/.config/hypr/hyprlock.conf` | Lock screen (gruvbox стиль) |
| `~/.config/hypr/hyprpaper.conf` | Генерується автоматично при старті |
| `~/.config/libinput-gestures.conf` | Жести тачпада (hyprctl команди) |

## Пакети для встановлення

```bash
sudo pacman -S hyprlock
```

## Хоткеї — що змінилось

| Клавіша | i3 | Hyprland |
|---------|-----|----------|
| `$mod+S` | layout stacking | **scratchpad toggle** (нова фіча) |
| `$mod+Shift+S` | — | move to scratchpad |
| `$mod+E` | layout toggle split | togglesplit (аналог) |
| `$mod+W` | layout tabbed | ❌ немає аналогу |
| `$mod+Shift+R` | restart i3 | `hyprctl reload` (тільки конфіг) |
| `$mod+Shift+L` | betterlockscreen | **hyprlock** |
| `$mod+X` | xrandr mode | hyprctl monitor mode |

## Хоткеї — однакові

- `$mod+Return` → kitty
- `$mod+D` → rofi (той самий)
- `$mod+Shift+Q` → kill
- `$mod+F` → fullscreen
- `$mod+Shift+Space` → float toggle
- `$mod+J/K/L/;` → focus vim-style
- `$mod+Shift+J/K/L/;` → move window vim-style
- `$mod+1..0` → workspace
- `$mod+Shift+1..0` → move to workspace
- `$mod+R` → resize mode
- `$mod+Shift+C` → reload config
- `$mod+Shift+E` → exit
- `Print` / `F9` → flameshot gui

## Жести тачпада

| Жест | Дія |
|------|-----|
| 3 пальці ← / → | workspace prev/next |
| 3 пальці ↑ | fullscreen toggle |
| 3 пальці ↓ | float toggle |
| 4 пальці ↑/↓ | togglesplit |
| pinch in 2 | kill window |
| pinch out 3 | reload config |

> libinput-gestures вже встановлено і додано в автостарт.

## Режим дисплею ($mod+X)

| Клавіша | Дія |
|---------|-----|
| `R` | DP-1 праворуч від eDP-1 |
| `L` | DP-1 ліворуч |
| `T` | DP-1 зверху |
| `B` | DP-1 знизу |
| `O` | DP-1 вимкнути |
| `Esc` / `Enter` | вийти з режиму |

## Що замінено

| X11/i3 | Wayland/Hyprland |
|--------|-----------------|
| polybar | waybar |
| feh | hyprpaper + wallpaper.sh |
| picom | вбудований compositor |
| betterlockscreen/i3lock | hyprlock |
| xrandr | hyprctl keyword monitor |
| setxkbmap | `kb_layout` в input {} |
| xinput | `touchpad {}` в input {} |
| libinput-gestures (i3-msg) | libinput-gestures (hyprctl) |
| xss-lock | hypridle (опційно) |
| dunst | dunst (працює на Wayland) |
