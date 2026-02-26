-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Open next buffer' })
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', { desc = 'Open previous buffer' })
vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>', { desc = 'Close buffer' })

vim.keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'Page down and center' })
vim.keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'Page up and center' })

vim.keymap.set('i', '<C-c>', '<Esc>', { desc = 'Exit insert mode' })

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without yanking' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Yank line to system clipboard' })
vim.keymap.set(
  'n',
  '<leader>rr',
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = 'Replace word under cursor' }
)

vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = 'Delete to black hole register' })
vim.keymap.set(
  'n',
  '<leader>mr',
  '<cmd>CellularAutomaton make_it_rain<CR>',
  { desc = '[M]ake it [R]ain (fun animation)' }
)

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = '[P]roject [V]iew (netrw)' })

-- Move lines in visual mode (J moves down, K moves up)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

vim.keymap.set('n', '<leader>fn', ':e %:p:h/', { desc = '[f]ile [n]ew in current buffer path' })
