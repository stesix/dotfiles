return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  branch = 'main',
  dependencies = { 'neovim/nvim-lspconfig' },

  config = function()
    -- Make Mason-managed binaries (including tree-sitter-cli) visible to Neovim's
    -- vim.system() calls, which use $PATH from the Neovim process environment.
    local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
    if not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
    end

    local parsers_to_install = {
      'vimdoc',
      'javascript',
      'typescript',
      'c',
      'lua',
      'rust',
      'jsdoc',
      'bash',
      'hcl',
      'terraform',
      'gitcommit',
      'diff',
      'git_rebase',
      'json',
      'markdown',
      'markdown_inline',
      'python',
      'templ',
    }

    local function install_parsers()
      require('nvim-treesitter').install(parsers_to_install)
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MasonToolInstallComplete',
      once = true,
      callback = install_parsers,
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function(ev)
        local ok = pcall(vim.treesitter.start, ev.buf)
        if not ok then
          -- No parser available for this filetype — fall back to syntax
          vim.bo[ev.buf].syntax = 'ON'
          return
        end

        -- Enable treesitter-based indentation (experimental)
        pcall(function()
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
}
