local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.font = wezterm.font("Operator Mono SSm")
config.font_size = 12
config.line_height = 1.5
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

return config
