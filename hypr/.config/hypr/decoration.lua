local colors = require("macchiato")

hl.config({
    decoration = {
        rounding         = 12,
        rounding_power   = 4,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 1,
            vibrancy = 0.18,
        },
    },
})

for _, ns in ipairs({ "rofi", "waybar" }) do
    hl.layer_rule({
        name         = "blur-" .. ns,
        match        = { namespace = ns },
        blur         = true,
        ignore_alpha = 0,
    })
end

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

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
