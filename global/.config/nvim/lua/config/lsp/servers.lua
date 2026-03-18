-- LSP server configurations
-- Add your LSP servers here with any custom settings

return {
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        diagnostics = {
          -- disable = { 'missing-fields' }
        },
        runtime = {
          version = 'Lua 5.5',
        },
      },
    },
    root_markers = {
      '.luarc.json',
      '.luarc.jsonc',
      '.luacheckrc',
      '.stylua.toml',
      '.git',
    },
  },

  bashls = {},
  terraformls = {},

  -- Python
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },

  -- TypeScript/JavaScript
  ts_ls = {},

  -- JSON
  jsonls = {},

  -- Markdown
  marksman = {},

  -- Add more servers as needed
  -- See `:help lspconfig-all` for available servers
  -- Note: Groovy LSP support is limited. Consider using the groovy-language-server if needed.
}
