-- Filetype detection configurations

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Terraform and HCL filetypes
local terraform = vim.api.nvim_create_augroup('terraform-filetype', { clear = true })

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = terraform,
  pattern = { '*.tf', '*.tfvars', '.terraformrc', 'terraform.rc', '*.hcl' },
  callback = function(args)
    local filename = args.file
    if filename:match('%.tfvars$') then
      vim.bo.filetype = 'terraform-vars'
    elseif filename:match('%.tf$') then
      vim.bo.filetype = 'terraform'
    elseif filename:match('%.tfstack%.hcl$') then
      vim.bo.filetype = 'terraform-stack'
    elseif filename:match('%.tfdeploy%.hcl$') then
      vim.bo.filetype = 'terraform-deploy'
    else
      vim.bo.filetype = 'hcl'
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = terraform,
  pattern = { '*.tfstate', '*.tfstate.backup' },
  callback = function()
    vim.bo.filetype = 'json'
  end,
})

-- Jenkins (Groovy)
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('jenkins-filetype', { clear = true }),
  pattern = 'Jenkinsfile*',
  callback = function()
    vim.bo.filetype = 'groovy'
  end,
})
