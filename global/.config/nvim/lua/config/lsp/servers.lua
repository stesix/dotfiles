-- LSP server configurations
-- Add your LSP servers here with any custom settings

return {
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- Uncomment to disable noisy 'missing-fields' warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },

  bashls = {},
  terraformls = {},
  -- pyright = {},
  -- ts_ls = {}, -- TypeScript/JavaScript
  -- jsonls = {},

  -- Add more servers as needed
  -- See `:help lspconfig-all` for available servers
}
