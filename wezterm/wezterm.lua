local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.max_fps = 120
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'Berkeley Mono'
config.font_size = 12
config.line_height = 1.4
config.window_decorations = 'TITLE | RESIZE'
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.audible_bell = 'Disabled'
config.window_padding = {
  left = '8',
  right = '8',
  top = '8',
  bottom = '8',
}
config.underline_position = -4
config.use_dead_keys = false
config.send_composed_key_when_left_alt_is_pressed = true
config.keys = {
  { key = 'n', mods = 'OPT', action = wezterm.action { SendString = '~' } },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
  {
    key = 'f',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = 'Enter',
    mods = 'ALT',
    action = 'DisableDefaultAssignment',
  },
}

return config
