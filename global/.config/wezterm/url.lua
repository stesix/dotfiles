local wezterm = require('wezterm')

local M = {}

function M.apply(config)
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  local jira_url = os.getenv('WEZTERM_JIRA_URL')
  if jira_url then
    table.insert(config.hyperlink_rules, {
      regex = [[(AH-\d{3,4})]],
      format = jira_url .. '/browse/$1',
    })
  end

  table.insert(config.hyperlink_rules, {
    regex = '\\bfile://\\S*\\b',
    format = '$0',
  })

  -- Now add a new item at the bottom to match things that are
  -- probably filenames
  table.insert(config.hyperlink_rules, {
    regex = '[/.A-Za-z0-9_-]+\\.[A-Za-z0-9]+(:\\d+)*(?=\\s*|$)',
    format = '$EDITOR:$0',
  })
end

return M
