local wezterm = require('wezterm')
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
    { key = 's', mods = 'LEADER|SHIFT', action = wezterm.action({ EmitEvent = 'save_session' }) },
    --    { key = 's', mods = 'LEADER', wezterm.action() },
    { key = 'l', mods = 'LEADER', action = wezterm.action({ EmitEvent = 'load_session' }) },
    {
      key = 'r',
      mods = 'LEADER|SHIFT',
      action = wezterm.action({ EmitEvent = 'restore_session' }),
    },
  }
end

return M
