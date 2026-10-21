local colors = require("macchiato")
local accent = colors.mauve

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 6,

        border_size = 2,

        col = {
            active_border = colors.glass,
            active_border   = accent,
            inactive_border = colors.glass,
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})
