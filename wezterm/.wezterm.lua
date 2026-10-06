local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.font_size = 14
config.enable_tab_bar = false
config.color_scheme = 'Catppuccin Macchiato'
--config.default_cursor_style = 'SteadyBar'
config.cursor_blink_rate = 600
config.force_reverse_video_cursor = true
return config
