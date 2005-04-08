local wezterm = require('wezterm')

local M = {}

function M.apply(config)
  config.mouse_bindings = {
    -- Disable the default click behavior
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
    -- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.Nop,
    },
  }
end

return M
