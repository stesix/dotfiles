local wezterm = require('wezterm')
local M = {}

local function get_pwd(pane)
  local pwd = pane:get_current_working_dir()
  return pwd.file_path
end

local function extract_filename(uri)
  local st, m_end = uri:find('$EDITOR:')
  if st == 1 then
    -- skip past the colon
    return uri:sub(m_end + 1)
  end

  -- `file://hostname/path/to/file`
  local start, match_end = uri:find('file:')
  if start == 1 then
    -- skip "file://", -> `hostname/path/to/file`
    local host_and_path = uri:sub(match_end + 3)
    local sub_start, sub_match_end = host_and_path:find('/')
    if sub_start then
      -- -> `/path/to/file`
      return host_and_path:sub(sub_match_end)
    end
  end

  return nil
end

local function extract_line_and_name(uri)
  local name = extract_filename(uri)

  if name then
    local line = 1
    -- check if name has a line number (e.g. `file:.../file.txt:123 or file:.../file.txt:123:456`)
    local start, match_end = name:find(':[0-9]+')
    if start then
      -- line number is 123
      line = name:sub(start + 1, match_end)
      -- remove the line number from the filename
      name = name:sub(1, start - 1)
    end

    return line, name
  end

  return nil, nil
end

local function open_in_nvim(window, full_path, line)
  local _, pane = window:spawn_tab()

  pane:send_text('nvim +' .. line .. ' ' .. full_path .. '\n')
end

M.setup = function()
  wezterm.on('open-uri', function(window, pane, uri)
    local line, name = extract_line_and_name(uri)

    if name then
      local pwd = get_pwd(pane)
      local full_path = pwd .. '/' .. name
      open_in_nvim(window, full_path, line)

      -- prevent the default action from opening in a browser
      return false
    end

    -- if email
    if uri:find('mailto:') == 1 then
      return false -- disable opening email
    end
  end)
end

return M
