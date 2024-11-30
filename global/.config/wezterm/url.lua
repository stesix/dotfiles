local wezterm = require('wezterm')

local M = {}

function M.apply(config)
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  -- https://jira.de.deloitte.com/browse/$ticket_id
  table.insert(config.hyperlink_rules, {
    regex = [[(AH-\d{3,4})]],
    format = 'https://jira.de.deloitte.com/browse/$1',
  })
end

return M
