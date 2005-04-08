local wezterm = require('wezterm')
local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
local act = wezterm.action

local M = {}

function M.apply(config)
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true
  config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }
  config.keys = {
    -- Tab management
    { key = 'c', mods = 'LEADER', action = act({ SpawnTab = 'CurrentPaneDomain' }) },
    { key = ' ', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    {
      key = '%',
      mods = 'CTRL|SHIFT|ALT',
      action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- Resurrect related keys
    {
      key = 'w',
      mods = 'ALT',
      action = wezterm.action_callback(function(win, pane)
        resurrect.save_state(resurrect.workspace_state.get_workspace_state())
      end),
    },
    {
      key = 'W',
      mods = 'ALT',
      action = resurrect.window_state.save_window_action(),
    },
    {
      key = 'T',
      mods = 'ALT',
      action = resurrect.tab_state.save_tab_action(),
    },
    {
      key = 's',
      mods = 'ALT',
      action = wezterm.action_callback(function(win, pane)
        resurrect.save_state(resurrect.workspace_state.get_workspace_state())
        resurrect.window_state.save_window_action()
      end),
    },
    {
      key = 'r',
      mods = 'ALT',
      action = wezterm.action_callback(function(win, pane)
        resurrect.fuzzy_load(win, pane, function(id, label)
          local type = string.match(id, '^([^/]+)') -- match before '/'
          id = string.match(id, '([^/]+)$') -- match after '/'
          id = string.match(id, '(.+)%..+$') -- remove file extention
          local opts = {
            relative = true,
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          }
          if type == 'workspace' then
            local state = resurrect.load_state(id, 'workspace')
            resurrect.workspace_state.restore_workspace(state, opts)
          elseif type == 'window' then
            local state = resurrect.load_state(id, 'window')
            resurrect.window_state.restore_window(pane:window(), state, opts)
          elseif type == 'tab' then
            local state = resurrect.load_state(id, 'tab')
            resurrect.tab_state.restore_tab(pane:tab(), state, opts)
          end
        end)
      end),
    },
  }
end

return M
