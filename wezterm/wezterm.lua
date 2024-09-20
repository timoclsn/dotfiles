local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'FiraCode Nerd Font Mono'
config.font_size = 12
config.line_height = 1.5
config.window_decorations = 'TITLE | RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.use_dead_keys = false
config.send_composed_key_when_left_alt_is_pressed = true
config.keys = {
  { key = 'n', mods = 'OPT', action = wezterm.action { SendString = '~' } },
  { key = '0', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[48;5u' },
  { key = '1', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[49;5u' },
  { key = '2', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[50;5u' },
  { key = '3', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[51;5u' },
  { key = '4', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[52;5u' },
  { key = '5', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[53;5u' },
  { key = '6', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[54;5u' },
  { key = '7', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[55;5u' },
  { key = '8', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[56;5u' },
  { key = '9', mods = 'CTRL', action = wezterm.action.SendString '\u{1b}[57;5u' },
  {
    key = 'f',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config
