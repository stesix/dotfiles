return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  branch = 'main', -- master branch is archived; main tracks Neovim 0.12+
  -- Ensure Mason (and tree-sitter-cli) is set up before this plugin runs
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
      'gitcommit',
      'diff',
      'git_rebase',
      'json',
      'markdown',
      'markdown_inline',
    }

    local function install_parsers()
      require('nvim-treesitter').install(parsers_to_install)
    end

    -- mason-tool-installer fires this event when all tools are done.
    -- If tree-sitter-cli is already installed (subsequent startups), it fires
    -- almost immediately; if it needed installing, we wait for it.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MasonToolInstallComplete',
      once = true,
      callback = install_parsers,
    })

    -- Also attempt install now in case mason-tool-installer already finished
    -- (e.g. all tools were already up-to-date and the event already fired).
    install_parsers()

    -- Enable treesitter highlighting for all filetypes.
    -- In nvim-treesitter main, highlighting is no longer auto-enabled;
    -- it must be wired up via FileType autocommands (Neovim 0.12+).
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function(ev)
        local ok = pcall(vim.treesitter.start, ev.buf)
        if not ok then
          -- No parser available for this filetype — fall back to syntax
          vim.bo[ev.buf].syntax = 'ON'
        end
      end,
    })

    -- Enable treesitter-based indentation (experimental)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function(ev)
        pcall(function()
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })

    -- Register custom templ parser
    local parsers = require('nvim-treesitter.parsers')
    parsers['templ'] = {
      install_info = {
        url = 'https://github.com/vrischmann/tree-sitter-templ.git',
        files = { 'src/parser.c', 'src/scanner.c' },
        branch = 'master',
      },
      tier = 3,
    }

    -- Register templ filetype with treesitter
    vim.treesitter.language.register('templ', 'templ')
  end,
}
