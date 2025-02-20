return {
  'akinsho/git-conflict.nvim',
  opts = {},
  config = function(_, opts)
    require('git-conflict').setup(opts)
  end,
}
