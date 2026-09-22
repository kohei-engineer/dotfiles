local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true

----------------------------------------------------
-- Window
----------------------------------------------------
config.window_background_opacity = 0.9

-- Hide the native title bar while retaining resize handles.
config.window_decorations = 'RESIZE'

-- Paint the whole window background solid black. The tab bar has no background
-- of its own (see window_frame below), so this is what shows through it.
config.window_background_gradient = {
  colors = { '#000000' },
}

----------------------------------------------------
-- Tab bar
----------------------------------------------------
-- Blend the tab bar into the window background.
config.window_frame = {
  inactive_titlebar_bg = 'none',
  active_titlebar_bg = 'none',
}

-- Hide the default border between inactive tabs; the custom arrows handle separation.
config.colors = {
  tab_bar = {
    inactive_tab_edge = 'none',
  },
}

-- Keep tab creation keyboard-driven.
config.show_new_tab_button_in_tab_bar = false
-- Hide the close button shown in each tab (nightly builds only).
config.show_close_tab_button_in_tabs = false

-- Powerline-style tab separators.
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  -- Choose the color according to whether the tab is active.
  local background = '#5c6d74'
  local foreground = '#FFFFFF'
  local edge_background = 'none'

  if tab.is_active then
    background = '#ae8b2d'
  end

  -- Pad and truncate the pane title so it fits in the tab bar.
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
-- Key bindings
----------------------------------------------------
-- Use only the key bindings defined below.
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

-- Launch Git Bash when opening a new window.
config.default_prog = {
  'C:\\Program Files\\Git\\bin\\bash.exe',
  '-l',
}

return config
