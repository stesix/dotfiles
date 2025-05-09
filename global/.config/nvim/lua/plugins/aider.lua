return {
  'GeorgesAlkhouri/nvim-aider',
  cmd = 'Aider',
  keys = {
    { '<leader>AA', '<cmd>Aider toggle<cr>', desc = 'Toggle Aider' },
    { '<leader>As', '<cmd>Aider send<cr>', desc = 'Send to Aider', mode = { 'n', 'v' } },
    { '<leader>Ac', '<cmd>Aider command<cr>', desc = 'Aider Commands' },
    { '<leader>Ab', '<cmd>Aider buffer<cr>', desc = 'Send Buffer' },
    { '<leader>Aa', '<cmd>Aider add<cr>', desc = 'Add File' },
    { '<leader>Ad', '<cmd>Aider drop<cr>', desc = 'Drop File' },
    { '<leader>Ar', '<cmd>Aider add readonly<cr>', desc = 'Add Read-Only' },
    { '<leader>AR', '<cmd>Aider reset<cr>', desc = 'Reset Session' },
    { '<leader>Ata', '<cmd>AiderTreeAddFile<cr>', desc = 'Add File from Tree to Aider', ft = 'NvimTree' },
    { '<leader>atd', '<cmd>AiderTreeDropFile<cr>', desc = 'Drop File from Tree from Aider', ft = 'NvimTree' },
  },
  dependencies = {
    'folke/snacks.nvim',
    'catppuccin/nvim',
    'nvim-tree/nvim-tree.lua',
    {
      'nvim-neo-tree/neo-tree.nvim',
      opts = function(_, opts)
        opts.window = {
          mappings = {
            ['+'] = { 'nvim_aider_add', desc = 'add to aider' },
            ['-'] = { 'nvim_aider_drop', desc = 'drop from aider' },
            ['='] = { 'nvim_aider_add_read_only', desc = 'add read-only to aider' },
          },
        }
        require('nvim_aider.neo_tree').setup(opts)
      end,
    },
  },
  config = true,
}
