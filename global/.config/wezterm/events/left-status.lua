local wezterm = require('wezterm')

local nf = wezterm.nerdfonts
local colorscheme_colors = wezterm.color.get_default_colors()
local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]

local colors = {
  glyph_semi_circle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '' },
  text = { bg = '#cba6f7', fg = '#1c1b19' },
}

---@param text string
---@param fg string
---@param bg string
local _push = function(__cells__, text, fg, bg)
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Background = { Color = bg } })
  table.insert(__cells__, { Attribute = { Intensity = 'Bold' } })
  table.insert(__cells__, { Text = text })
end

M.setup = function()
  -- NOTE: WezTerm fires 'update-right-status' for both left and right status bars.
  wezterm.on('update-right-status', function(window, _pane)
    local __cells__ = {}

    local name = window:active_key_table()
    if name then
      _push(
        __cells__,
        GLYPH_SEMI_CIRCLE_LEFT,
        colors.glyph_semi_circle.fg,
        colors.glyph_semi_circle.bg
      )
      _push(__cells__, GLYPH_KEY_TABLE, colors.text.fg, colors.text.bg)
      _push(__cells__, ' ' .. string.upper(name), colors.text.fg, colors.text.bg)
      _push(
        __cells__,
        GLYPH_SEMI_CIRCLE_RIGHT,
        colors.glyph_semi_circle.fg,
        colors.glyph_semi_circle.bg
      )
    end

    if window:leader_is_active() then
      _push(
        __cells__,
        GLYPH_SEMI_CIRCLE_LEFT,
        colors.glyph_semi_circle.fg,
        colors.glyph_semi_circle.bg
      )
      _push(__cells__, GLYPH_KEY, colors.text.fg, colors.text.bg)
      _push(__cells__, ' ', colors.text.fg, colors.text.bg)
      _push(
        __cells__,
        GLYPH_SEMI_CIRCLE_RIGHT,
        colors.glyph_semi_circle.fg,
        colors.glyph_semi_circle.bg
      )
    end

    window:set_left_status(wezterm.format(__cells__))
  end)
end

return M
