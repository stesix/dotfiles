local M = {}

local wezterm = require('wezterm')
local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm')
resurrect.periodic_save()

local workspace_state = require(resurrect.get_require_path() .. '.plugin.resurrect.workspace_state')

function M.apply(config)
  config.keys = {
    key = 's',
    mods = 'ALT',
    action = wezterm.action.Multiple({
      wezterm.action_callback(function(win, pane)
        local resurrect = wezterm.plugin.require('https://github.com/MLFlexer/resurrect.wezterm/')
        resurrect.save_state(workspace_state.get_workspace_state())
      end),
    }),
  }
end

return M
