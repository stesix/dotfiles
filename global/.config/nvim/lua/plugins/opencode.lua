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

    vim.keymap.set({ 'n', 'x' }, '<C-a>', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode' })

    vim.keymap.set({ 'n', 'x' }, '<C-x>', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })

    vim.keymap.set({ 'n', 'x' }, 'ga', function()
      require('opencode').prompt('@this')
    end, { desc = 'Add to opencode' })

    vim.keymap.set({ 'n', 't' }, '<C-.>', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })

    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command('session.half.page.up')
    end, { desc = 'opencode half page up' })

    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command('session.half.page.down')
    end, { desc = 'opencode half page down' })

    -- Restore increment/decrement functionality since <C-a> and <C-x> are used for OpenCode
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment number', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement number', noremap = true })
    vim.keymap.set('x', '+', 'g<C-a>', { desc = 'Increment numbers (visual)', noremap = true })
    vim.keymap.set('x', '-', 'g<C-x>', { desc = 'Decrement numbers (visual)', noremap = true })
  end,
}
