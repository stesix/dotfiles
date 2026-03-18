return {
  'folke/trouble.nvim',
  version = '*',
  cmd = 'Trouble',
  opts = {},
  keys = {
    { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = '[T]rouble [T]oggle diagnostics' },
    {
      '[t',
      function()
        require('trouble').prev({ skip_groups = true, jump = true })
      end,
      desc = 'Previous [T]rouble item',
    },
    {
      ']t',
      function()
        require('trouble').next({ skip_groups = true, jump = true })
      end,
      desc = 'Next [T]rouble item',
    },
  },
}
