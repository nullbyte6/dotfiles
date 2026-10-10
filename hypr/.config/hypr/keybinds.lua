local programs = require("programs")

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q",          hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + W",          hl.dsp.window.close())
hl.bind(mainMod .. " + M",          hl.dsp.exit())
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + F",          hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V",          hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",      hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd(programs.powermenu))
hl.bind(mainMod .. " + P",          hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",          hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())

hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + TAB",   hl.dsp.focus({ workspace = "+1" }))

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local mediaOpts = { locked = true, repeating = true }
hl.bind(mainMod .. " + SHIFT + up",   hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), mediaOpts)
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      mediaOpts)
hl.bind(mainMod .. " + SHIFT + M",    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     mediaOpts)
hl.bind("XF86AudioMicMute",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   mediaOpts)
hl.bind("XF86MonBrightnessUp",        hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  mediaOpts)
hl.bind("XF86MonBrightnessDown",      hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  mediaOpts)

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + ALT + G",   hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + ALT + V",   hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + O",         hl.dsp.exec_cmd("noctalia"))
hl.bind(mainMod .. " + CTRL + O",  hl.dsp.exec_cmd("pkill noctalia"))
