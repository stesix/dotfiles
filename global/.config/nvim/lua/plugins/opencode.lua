return {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      enabled = 'snacks',
      snacks = {},
    }

    -- Required for `opts.auto_reload`.
    vim.o.autoread = true

    -- Leader-based mappings (aider-style organization under <leader>A)
    vim.keymap.set({ 'n', 't' }, '<leader>OO', function()
      require('opencode').toggle()
    end, { desc = 'Toggle OpenCode' })

    vim.keymap.set({ 'n', 'x' }, '<leader>Os', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Send to OpenCode' })

    vim.keymap.set({ 'n', 'x' }, '<leader>Oc', function()
      require('opencode').select()
    end, { desc = 'OpenCode Commands' })

    vim.keymap.set('n', '<leader>Ob', function()
      require('opencode').ask('@buffer: ', { submit = true })
    end, { desc = 'Send Buffer to OpenCode' })

    vim.keymap.set('n', '<leader>Of', function()
      require('opencode').prompt('@file ')
    end, { desc = 'Add File context' })

    vim.keymap.set('n', '<leader>OR', function()
      require('opencode').command('session.clear')
    end, { desc = 'Reset OpenCode Session' })

    -- Scrolling in OpenCode window
    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command('session.half.page.up')
    end, { desc = 'Scroll OpenCode up' })

    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command('session.half.page.down')
    end, { desc = 'Scroll OpenCode down' })

    -- Restore increment/decrement functionality since <C-a> and <C-x> are used for OpenCode
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment number', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement number', noremap = true })
    vim.keymap.set('x', '+', 'g<C-a>', { desc = 'Increment numbers (visual)', noremap = true })
    vim.keymap.set('x', '-', 'g<C-x>', { desc = 'Decrement numbers (visual)', noremap = true })
  end,
}
