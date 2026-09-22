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

-- Shells report their working directory as the title, so every tab looks the
-- same once truncated. Show just the directory name for those; other programs
-- set a more useful title than we could build, so leave theirs alone.
local SHELLS = {
  bash = true,
  sh = true,
  zsh = true,
  fish = true,
  pwsh = true,
  powershell = true,
  cmd = true,
}

local function basename(path)
  local trimmed = path:gsub('[/\\]+$', '')
  local name = trimmed:gsub('.*[/\\]', '')
  return name
end

local function tab_name(tab)
  -- A name set by hand with Leader+, always wins.
  if tab.tab_title and #tab.tab_title > 0 then
    return tab.tab_title
  end

  local pane = tab.active_pane
  local process = basename(pane.foreground_process_name or '')
  local shell = process:gsub('%.exe$', '')

  if SHELLS[shell] and pane.current_working_dir then
    local dir = basename(pane.current_working_dir.file_path)
    if #dir > 0 then
      return dir
    end
  end

  return pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  -- Choose the color according to whether the tab is active.
  local background = '#5c6d74'
  local foreground = '#FFFFFF'
  local edge_background = 'none'

  if tab.is_active then
    background = '#ae8b2d'
  end

  local title = ' ' .. wezterm.truncate_right(tab_name(tab), max_width - 1) .. ' '

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

-- Multiplexer operations sit behind LEADER so that they stay identical on
-- Windows and macOS, and need no arrow, symbol or Fn keys.
config.leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

  -- Split the way vim's :vsplit / :split do.
  { key = 'v', mods = 'LEADER', action = act.SplitPane { direction = 'Right' } },
  { key = 's', mods = 'LEADER', action = act.SplitPane { direction = 'Down' } },

  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },

  -- Leader+r: enter resize mode; it stays active until Escape or Enter.
  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false },
  },

  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      domain = 'CurrentPaneDomain',
    },
  },

  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

  -- Renaming matches tmux's prefix+,. Submitting an empty line clears the name
  -- and returns to the automatic one.
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'New tab name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  { key = 'm', mods = 'LEADER', action = act.ActivateCopyMode },

  { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
}

config.key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = act.PopKeyTable },
    { key = 'Enter', action = act.PopKeyTable },
  },
}

----------------------------------------------------
-- Status line
----------------------------------------------------
-- Surface a pending LEADER and the active key table; without this there is no
-- way to tell that resize mode is still on. The default 1000ms poll is too
-- slow to be useful against the 1000ms leader timeout.
config.status_update_interval = 250

wezterm.on('update-status', function(window, pane)
  local status = ''

  if window:leader_is_active() then
    status = 'LEADER'
  elseif window:active_key_table() == 'resize_pane' then
    status = 'RESIZE'
  end

  if status == '' then
    window:set_right_status ''
    return
  end

  window:set_right_status(wezterm.format {
    { Background = { Color = '#ae8b2d' } },
    { Foreground = { Color = '#FFFFFF' } },
    { Text = ' ' .. status .. ' ' },
  })
end)

-- Launch Git Bash when opening a new window.
config.default_prog = {
  'C:\\Program Files\\Git\\bin\\bash.exe',
  '-l',
}

return config
