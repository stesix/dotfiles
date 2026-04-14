return {
  'Willem-J-an/adopure.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'sindrets/diffview.nvim',
    'nvim-neotest/nvim-nio',
  },
  cmd = { 'AdoPure' }, -- lazy-load only when actually used
  config = function()
    vim.g.adopure = {}

    -- Guard: skip keyring lookup if env vars are not set
    if not vim.env.KEYRING_NEOVIM or not vim.env.AZURE_USER_NAME then
      return
    end

    local nio = require('nio')
    nio.run(function()
      local secret_job =
        nio.process.run({ cmd = 'keyring', args = { 'get', vim.env.KEYRING_NEOVIM, vim.env.AZURE_USER_NAME } })
      if secret_job then
        vim.g.adopure = { pat_token = secret_job.stdout.read():sub(1, -2) }
      end
    end)
  end,
}
