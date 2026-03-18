-- LSP keymaps configuration
-- These keymaps are set when an LSP attaches to a buffer

local M = {}

function M.setup(event)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- Navigation
  map('gd', function()
    require('telescope.builtin').lsp_definitions()
  end, '[G]oto [D]efinition')
  map('gr', function()
    require('telescope.builtin').lsp_references()
  end, '[G]oto [R]eferences')
  map('gI', function()
    require('telescope.builtin').lsp_implementations()
  end, '[G]oto [I]mplementation')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('<leader>lD', function()
    require('telescope.builtin').lsp_type_definitions()
  end, 'Type [D]efinition')

  -- Symbols
  map('<leader>ds', function()
    require('telescope.builtin').lsp_document_symbols()
  end, '[D]ocument [S]ymbols')
  map('<leader>ws', function()
    require('telescope.builtin').lsp_dynamic_workspace_symbols()
  end, '[W]orkspace [S]ymbols')

  -- Actions
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  map('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Inlay hints toggle
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
end

return M
