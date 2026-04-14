-- Filetype detection configurations

vim.filetype.add({
  extension = {
    ['tfstate'] = 'json',
    ['tfstate.backup'] = 'json',
  },
  pattern = {
    ['.*%.tfstack%.hcl'] = 'terraform-stack',
    ['.*%.tfdeploy%.hcl'] = 'terraform-deploy',
  },
})

-- Jenkins (Groovy)
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('jenkins-filetype', { clear = true }),
  pattern = 'Jenkinsfile*',
  callback = function()
    vim.bo.filetype = 'groovy'
  end,
})
