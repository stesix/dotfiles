-- LSP document highlight configuration
-- Highlights references of the symbol under cursor

local M = {}

function M.setup(event, client)
  if not client or not client.server_capabilities.documentHighlightProvider then
    return
  end

  local highlight_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = event.buf,
    group = highlight_group,
    callback = vim.lsp.buf.document_highlight,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    buffer = event.buf,
    group = highlight_group,
    callback = vim.lsp.buf.clear_references,
  })

  -- Clean up on LSP detach
  vim.api.nvim_create_autocmd('LspDetach', {
    buffer = event.buf,
    callback = function()
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = event.buf })
    end,
  })
end

return M
