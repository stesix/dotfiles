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

  ts_ls = {},

  jsonls = {},

  marksman = {},
}
