return {
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  config = function()
    local smart_splits = require('smart-splits')

    smart_splits.setup()

    vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left, { desc = 'Move to left split' })
    vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down, { desc = 'Move to below split' })
    vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up, { desc = 'Move to above split' })
    vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right, { desc = 'Move to right split' })
  end,
}
