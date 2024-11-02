local wezterm = require('wezterm')

local nf = wezterm.nerdfonts
local cs_colors = wezterm.color.get_builtin_schemes()['Catppuccin Mocha']
local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]

local colors = {
  date = cs_colors.ansi[5],
  folder = cs_colors.ansi[6],
}

local __cells__ = {} -- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

local basename = function(s, t)
  if t == 'cmd' then
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
  end

  -- Nothing a little regex can't fix
  return s
end

---@param text string
---@param icon string
---@param fg string
local _push = function(text, icon, fg)
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Background = { Color = cs_colors.background } })
  table.insert(__cells__, { Text = GLYPH_SEMI_CIRCLE_LEFT })
  table.insert(__cells__, { Background = { Color = fg } })
  table.insert(__cells__, { Foreground = { Color = '#313244' } })
  table.insert(__cells__, { Text = icon .. '  ' })

  table.insert(__cells__, { Foreground = { Color = cs_colors.foreground } })
  table.insert(__cells__, { Background = { Color = '#313244' } })
  table.insert(__cells__, { Attribute = { Intensity = 'Bold' } })
  table.insert(__cells__, { Text = ' ' .. text })
  table.insert(__cells__, { Foreground = { Color = '#313244' } })
  table.insert(__cells__, { Background = { Color = cs_colors.background } })
  table.insert(__cells__, { Text = GLYPH_SEMI_CIRCLE_RIGHT .. ' ' })
end

local _set_working_dir = function(pane)
  local cwd = pane:get_current_working_dir()
  if cwd then
    if type(cwd) == 'userdata' then
      -- Wezterm introduced the URL object in 20240127-113634-bbcac864
      cwd = basename(cwd.file_path, 'folder')
    else
      -- 20230712-072601-f4abf8fd or earlier version
      cwd = basename(cwd, 'folder')
    end
  else
    cwd = ''
  end

  _push(cwd, nf.fa_folder, colors.folder)
end

local _set_date = function(pane)
  local date = wezterm.strftime('%Y-%m-%d %H:%M')
  _push(date, nf.md_calendar_clock, colors.date)
end

M.setup = function()
  wezterm.on('update-right-status', function(window, _pane)
    __cells__ = {}
    _set_working_dir(_pane)
    _set_date(_pane)

    window:set_right_status(wezterm.format(__cells__))
  end)
end

return M
