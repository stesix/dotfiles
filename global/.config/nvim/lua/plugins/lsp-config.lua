-- LSP Configuration & Plugins
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  config = function()
    local keymaps = require('config.lsp.keymaps')
    local highlight = require('config.lsp.highlight')
    local servers = require('config.lsp.servers')

    -- Setup LSP attach behavior
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        keymaps.setup(event)
        highlight.setup(event, client)
      end,
    })

    -- Configure LSP capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Setup Mason
    require('mason').setup()

    -- Setup mason-lspconfig (LSP servers only)
    require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = false,
      handlers = {
        function(server_name)
          -- Exclude formatters incorrectly listed as LSP servers
          local non_lsp_tools = { 'stylua', 'black', 'prettier', 'eslint_d' }
          if vim.tbl_contains(non_lsp_tools, server_name) then
            return
          end

          -- Setup only explicitly configured servers
          if servers[server_name] then
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end
        end,
      },
    })

    -- Install additional tools (formatters, linters)
    local tools = vim.tbl_keys(servers)
    -- Add non-LSP tools here if needed (formatters, linters)
    -- Note: stylua is installed via Homebrew to avoid mason-lspconfig bug

    require('mason-tool-installer').setup({ ensure_installed = tools })
  end,
}
