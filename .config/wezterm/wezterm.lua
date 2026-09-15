local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.window_background_opacity = 0.9

----------------------------------------------------
-- Tab
----------------------------------------------------
-- Hide the native title bar while keeping resize handles.
config.window_decorations = 'RESIZE'

-- Blend the tab bar into the window background.
config.window_frame = {
  inactive_titlebar_bg = 'none',
  active_titlebar_bg = 'none',
}

config.window_background_gradient = {
  colors = { '#000000' },
}

-- Keep tab creation keyboard-driven.
config.show_new_tab_button_in_tab_bar = false

-- Powerline-style tab separators.
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local background = '#5c6d74'
  local foreground = '#FFFFFF'
  local edge_background = 'none'

  if tab.is_active then
    background = '#ae8b2d'
  end

  local title = '   ' .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. '   '

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = background } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = background } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- Keybinds
----------------------------------------------------
config.disable_default_key_bindings = true

config.keys = {
  -- Ctrl+Shift+N: open a new tab in the home directory.
  {
    key = 'N',
    mods = 'CTRL',
    action = act.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      domain = 'CurrentPaneDomain',
    },
  },

  -- Ctrl+Shift+W: close the current tab after confirmation.
  { key = 'W', mods = 'CTRL', action = act.CloseCurrentTab({ confirm = true }) },

  -- Ctrl+Shift+R/L/T/B: add a pane to the right/left/top/bottom.
  { key = 'R', mods = 'CTRL', action = act.SplitPane { direction = 'Right' } },
  { key = 'L', mods = 'CTRL', action = act.SplitPane { direction = 'Left' } },
  { key = 'T', mods = 'CTRL', action = act.SplitPane { direction = 'Up' } },
  { key = 'B', mods = 'CTRL', action = act.SplitPane { direction = 'Down' } },

  -- Ctrl+Shift+Arrow: resize the active pane.
  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Left', 1 }) },
  { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Down', 1 }) },
  { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Up', 1 }) },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize({ 'Right', 1 }) },

  -- Alt+Arrow: move focus between panes.
  { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

  -- Ctrl+Tab / Ctrl+Shift+Tab: next/previous tab.
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- Ctrl+Shift+M: enter Copy Mode.
  { key = 'M', mods = 'CTRL', action = act.ActivateCopyMode },

  -- Ctrl+Shift+C / V: copy from / paste to the system clipboard.
  { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
}

-- Launch Git Bash by default.
config.default_prog = {
  'C:\\Program Files\\Git\\bin\\bash.exe',
  '-l',
}

return config
