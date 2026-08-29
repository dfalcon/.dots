------------------
---- MONITORS ----
------------------

-- керування через nwg-displays ($mod+X), пише саме в monitors.lua
require("monitors")

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local menu     = "wofi --show drun"
local mainMod  = "SUPER"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- DPI для XWayland: з force_zero_scaling X11-додатки бачать голі 3072x1920
    -- без даних про масштаб і вважають DPI=96. Steam ("масштабувати відповідно
    -- до налаштувань монітора"), Java та GTK-X11 читають саме Xft.dpi.
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal --replace")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 flameshot")
    hl.exec_cmd("libinput-gestures-setup start")
    hl.exec_cmd("blueman-applet")
    -- Обхід бага Hyprland: при зміні фокуса вікно отримує чужу xkb-групу
    -- (github.com/hyprwm/Hyprland/issues/8776, тягнеться з 0.52.0). Демон сам
    -- виставляє розкладку вікну на фокусі — кожне вікно памʼятає свою мову.
    hl.exec_cmd("hyprland-per-window-layout")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/Pictures/Wallpapers/wallpaper-rotator.sh -q \"laptop\" -c anime")
    hl.exec_cmd("firefox")
    hl.exec_cmd("spotify")
    hl.exec_cmd("~/.config/hypr/spotify-notify.sh")
    hl.exec_cmd("Telegram")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/tg-media-follow.py")
    hl.exec_cmd("/home/dfalcon/Downloads/timedoctor-desktop_3.12.16_wayland_linux-x86_64.AppImage --no-sandbox")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        -- Tokyo Night
        col = {
            active_border   = { colors = { "rgba(7aa2f7ee)", "rgba(bb9af7ee)" }, angle = 45 },
            inactive_border = "rgba(24283baa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1b26,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    -- XWayland на HiDPI: без цього X11-додатки (Steam, TLauncher, Java)
    -- малюються в 1x і розтягуються композитором до scale 1.6 -> мило.
    -- З force_zero_scaling вони отримують нативні 3072x1920 і рендерять різко,
    -- але стають дрібними -> масштаб задається кожному окремо через env.
    xwayland = {
        force_zero_scaling = true,
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,

        -- если hyprlock умрёт при locked-сессии — даёт новому инстансу перехватить
        -- лок вместо красного экрана "lockscreen died"
        allow_session_lock_restore = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us, ru, ua",
        kb_variant = ", ,",
        -- Штатний xkb-перемикач. Демон hyprland-per-window-layout читає
        -- activelayout і сам переписує ВСІ клавіатури при кожному фокусі, тому
        -- тримати їх у синхроні вручну не потрібно. Бінд через
        -- `switchxkblayout all` тут шкідливий: демон таких змін не помічає,
        -- не оновлює памʼять вікна і при поверненні ставить старе значення.
        kb_options = "grp:alt_shift_toggle",

        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = false,
            tap_to_click   = true,
        },
    },
})

-- Жести — нативна підтримка Hyprland
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "down",       action = "float" })
hl.gesture({ fingers = 4, direction = "up",         action = "close" })

---------------------
---- KEYBINDINGS ----
---------------------

-- Термінал і лаунчер
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd(menu))

-- Вікна
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space",         hl.dsp.focus({ urgent_or_last = true }))
hl.bind(mainMod .. " + A",             hl.dsp.layout("focusmaster"))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())

-- Split/layout — dwindle togglesplit (= i3 $mod+e layout toggle split)
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"))

-- Блокування ($mod+Shift+L — як в i3)
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprctl switchxkblayout all 0 && hyprlock"))

-- Фокус — vim-стиль (як в i3: j=left, k=down, l=up, semicolon=right)
-- + стрілки
local focusDirs = {
    { keys = { "J", "left"  }, dir = "l" },
    { keys = { "K", "down"  }, dir = "d" },
    { keys = { "L", "up"    }, dir = "u" },
    { keys = { "semicolon", "right" }, dir = "r" },
}
for _, d in ipairs(focusDirs) do
    for _, k in ipairs(d.keys) do
        hl.bind(mainMod .. " + " .. k,             hl.dsp.focus({ direction = d.dir }))
        hl.bind(mainMod .. " + SHIFT + " .. k,     hl.dsp.window.move({ direction = d.dir }))
    end
end

-- Воркспейси + переміщення вікна на воркспейс
for i = 1, 10 do
    local key = i % 10 -- 10 → клавіша 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad ($mod+S — замість i3 stacking layout)
hl.bind(mainMod .. " + M",         hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:music", follow = false }))
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))

-- Скрол через воркспейси колесом миші
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Переміщення/ресайз мишею
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Скріншоти
hl.bind("Print", hl.dsp.exec_cmd("QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 flameshot gui"))
hl.bind("F9",    hl.dsp.exec_cmd([[grim -g "$(slurp)" ~/Pictures/$(date +%Y%m%d_%H%M%S).png]]))

-- Аудіо
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Яскравість
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Перезавантаження конфігу ($mod+Shift+C і +R, як в i3)
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload; killall waybar; setsid waybar"))

-- Вихід ($mod+Shift+E, як в i3)
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- === РЕЖИМ РЕСАЙЗУ ($mod+R) ===
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    -- vim-стиль (j=shrink width, k=grow height, l=shrink height, ;=grow width)
    local resizeDirs = {
        { keys = { "J", "left"  }, x = -10, y = 0 },
        { keys = { "K", "down"  }, x = 0,   y = 10 },
        { keys = { "L", "up"    }, x = 0,   y = -10 },
        { keys = { "semicolon", "right" }, x = 10, y = 0 },
    }
    for _, r in ipairs(resizeDirs) do
        for _, k in ipairs(r.keys) do
            hl.bind(k, hl.dsp.window.resize({ x = r.x, y = r.y, relative = true }), { repeating = true })
        end
    end

    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- Управління дисплеями ($mod+X)
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("nwg-displays"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Прозорість kitty
hl.window_rule({
    name  = "kitty-opacity",
    match = { class = "^(kitty)$" },
    opacity = "0.9 0.9",
})

-- Автоприсвоєння воркспейсів (як for_window в i3)
hl.window_rule({
    name  = "ws-firefox",
    match = { class = "^(firefox|Firefox)$" },
    workspace = "1 silent",
})
hl.window_rule({
    name  = "ws-spotify",
    match = { class = "^(Spotify|spotify)$" },
    workspace = "special:music silent",
})
hl.window_rule({
    name  = "ws-telegram",
    match = {
        class = "^(org\\.telegram\\.desktop|Telegram|TelegramDesktop)$",
        -- просмотрщик медіа має той самий class — без цього він теж їде в special:music і зникає
        title = "negative:^Media viewer$",
    },
    workspace = "special:music silent",
})
-- Переглядач медіа ТГ їде за головним вікном — див. exec_cmd tg-media-follow.py
hl.window_rule({
    name  = "ws-timedoctor",
    match = { class = "^(Time Doctor|timedoctor)$" },
    workspace = "10 silent",
})

-- Flameshot
hl.window_rule({
    name  = "flameshot-float",
    match = { class = "^(flameshot)$" },
    float = true,
    move  = "0 0",
    pin   = true,
})

-- Подавити maximize requests
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Фікс XWayland drag
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- УВАГА: no_focus тут БУВ і ламав модальні діалоги — у діалогу довіри до
-- проекту title теж порожній, правило ловило і його. Лишаємо тільки
-- no_initial_focus: тултипи не крадуть фокус при появі, але діалог клікається.
-- Тултипи JetBrains — окремі toplevel'и з порожнім title, крадуть фокус → блимає рамка
hl.window_rule({
    name  = "jetbrains-tooltip-nofocus",
    match = {
        class = "^jetbrains-.*$",
        title = "^$",
    },
    no_initial_focus = true,
    no_anim  = true,
    float       = true,
    move        = "cursor_x+12 cursor_y+20",
    border_size = 0,
    rounding    = 0,
    no_shadow   = true,
    no_blur     = true,
})
