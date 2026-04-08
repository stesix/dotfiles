return {
  'Willem-J-an/adopure.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'sindrets/diffview.nvim',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    vim.g.adopure = {}

    local nio = require('nio')
    nio.run(function()
      local secret_job =
        nio.process.run({ cmd = 'keyring', args = { 'get', vim.env.KEYRING_NEOVIM, vim.env.AZURE_USER_NAME } })
      vim.g.adopure = { pat_token = secret_job.stdout.read():sub(1, -2) }
    end)
  end,
}
