local wezterm = require('wezterm')

local M = {}

local recompute_padding = function(window)
  local window_dims = window:get_dimensions()
  local overrides = window:get_config_overrides() or {}

  -- if not window_dims.is_full_screen then
  --   if not overrides.window_padding then
  --     -- not changing anything
  --     return
  --   end
  --   overrides.window_padding = nil
  -- else
  --   -- Use only the middle 33%
  --   local third = math.floor(window_dims.pixel_width / 3)
  --   local new_padding = {
  --     left = third,
  --     right = third,
  --     top = 0,
  --     bottom = 0,
  --   }
  --   if overrides.window_padding and new_padding.left == overrides.window_padding.left then
  --     -- padding is same, avoid triggering further changes
  --     return
  --   end
  --   overrides.window_padding = new_padding
  -- end
  window:set_config_overrides(overrides)
end

M.setup = function()
  wezterm.on('window-resized', function(window, pane)
    recompute_padding(window)
  end)

  wezterm.on('window-config-reloaded', function(window)
    recompute_padding(window)
  end)
end

return M
