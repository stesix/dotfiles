-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.cmd [[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]]
vim.cmd [[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]]
vim.cmd [[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]]
vim.cmd [[autocmd BufRead,BufNewFile *.tf set filetype=terraform]]
vim.cmd [[autocmd BufRead,BufNewFile *.tfvars set filetype=terraform-vars]]
vim.cmd [[autocmd BufRead,BufNewFile *.tfstack.hcl set filetype=terraform-stack]]
vim.cmd [[autocmd BufRead,BufNewFile *.tfdeploy.hcl set filetype=terraform-deploy]]
vim.cmd [[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]]
vim.cmd [[autocmd BufRead,BufNewFile Jenkinsfile* set filetype=groovy]]

vim.cmd [[let g:terraform_fmt_on_save=1]]
vim.cmd [[let g:terraform_align=1]]
