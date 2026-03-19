local wezterm = require('wezterm')
local cs_colors = wezterm.color.get_builtin_schemes()['Catppuccin Mocha']

-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614

local nf = wezterm.nerdfonts

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_CIRCLE = nf.fa_circle --[[ '' ]]

local M = {}

-- stylua: ignore
local colors = {
   default   = {
    left = { bg = '#313244', fg = cs_colors.foreground },
    right = { bg = cs_colors.ansi[5], fg = '#1c1b19' },
  },
   is_active = {
    left = { bg = '#fab387', fg = '#11111b' },
    right = { bg = '#fab387', fg = '#11111b' },
  },
  hover     = {
    left = { bg = '#313244', fg = '#1c1b19' },
    right = { bg = '#587d8c', fg = '#1c1b19' },
  },
}

local _set_process_name = function(s)
  local a = string.gsub(s, '(.*[/\\])(.*)', '%2')
  return a:gsub('%.exe$', '')
end

local MAX_TITLE_LEN = 30

local _set_title = function(process_name, base_title)
  local title

  if process_name:len() > 0 then
    title = process_name
  else
    title = base_title
  end

  if #title > MAX_TITLE_LEN then
    title = title:sub(1, MAX_TITLE_LEN - 1) .. '…'
  end

  return title
end

---@param fg string
---@param bg string
---@param attribute table
---@param text string
local _push = function(__cells__, bg, fg, attribute, text)
  table.insert(__cells__, { Background = { Color = bg } })
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Attribute = attribute })
  table.insert(__cells__, { Text = text })
end

M.setup = function()
  wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover)
    local __cells__ = {} -- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

    local left_bg
    local left_fg
    local right_bg
    local right_fg
    local process_name = _set_process_name(tab.active_pane.foreground_process_name)
    local title = _set_title(process_name, tab.active_pane.title)

    if tab.is_active then
      left_bg = colors.is_active.left.bg
      left_fg = colors.is_active.left.fg
      right_bg = colors.is_active.right.bg
      right_fg = colors.is_active.right.fg
    elseif hover then
      left_bg = colors.hover.left.bg
      left_fg = colors.hover.left.fg
      right_bg = colors.hover.right.bg
      right_fg = colors.hover.right.fg
    else
      left_bg = colors.default.left.bg
      left_fg = colors.default.left.fg
      right_bg = colors.default.right.bg
      right_fg = colors.default.right.fg
    end

    local has_unseen_output = false
    for _, pane in ipairs(tab.panes) do
      if pane.has_unseen_output then
        has_unseen_output = true
        break
      end
    end

    -- Left semi-circle
    _push(__cells__, cs_colors.background, right_bg, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_LEFT)

    -- Tab number (leftmost so it survives clipping)
    _push(__cells__, right_bg, right_fg, { Intensity = 'Bold' }, tab.tab_index + 1 .. '|')

    -- Title
    _push(__cells__, left_bg, left_fg, { Intensity = 'Bold' }, ' ' .. title .. ' ')

    -- Unseen output alert
    if has_unseen_output then
      _push(__cells__, left_bg, '#f2cdcd', { Intensity = 'Bold' }, GLYPH_CIRCLE .. ' ')
    else
      _push(__cells__, left_bg, '#f2cdcd', { Intensity = 'Bold' }, '  ')
    end

    -- Right semi-circle
    _push(__cells__, 'rgba(0, 0, 0, 0.4)', left_bg, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_RIGHT)

    return __cells__
  end)
end

return M
