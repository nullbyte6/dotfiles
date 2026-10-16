local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.font_size = 14
config.enable_tab_bar = false
config.color_scheme = 'Catppuccin Macchiato'
--config.default_cursor_style = 'SteadyBar'
config.cursor_blink_rate = 600
config.force_reverse_video_cursor = true
config.font = wezterm.font_with_fallback({
  "JetBrains Mono NL",
  { family = "Symbols Nerd Font Mono", scale = 1.2 },
  "Noto Sans Symbols 2",
  "Noto Color Emoji",
})
return config
