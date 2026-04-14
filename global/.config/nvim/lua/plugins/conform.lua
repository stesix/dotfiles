return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' }, -- Load before saving to enable format_on_save
  cmd = { 'ConformInfo' }, -- Also load when running :ConformInfo command
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local lsp_fallback_fts = { lua = true }
      return {
        timeout_ms = 500,
        lsp_fallback = lsp_fallback_fts[vim.bo[bufnr].filetype] or false,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
    },
  },
}
