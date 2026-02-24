return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false, -- Keep false to ensure loading for Neo-tree
  main = 'nvim-treesitter.configs', -- Lazy handles the require logic here
  branch = 'master', -- Explicitly force the stable branch

  opts = {

    -- A list of parser names, or "all"
    ensure_installed = {
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
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
    auto_install = true,

    indent = {
      enable = true,
    },

    highlight = {
      -- `false` will disable the whole extension
      enable = true,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = { 'markdown' },
    },
  },
  config = function(_, opts)
    -- Prefer git for treesitter installations
    require('nvim-treesitter.install').prefer_git = true

    -- Setup treesitter with opts (lazy.nvim handles errors gracefully)
    require('nvim-treesitter.configs').setup(opts)

    -- Add custom templ parser configuration
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.templ = {
      install_info = {
        url = 'https://github.com/vrischmann/tree-sitter-templ.git',
        files = { 'src/parser.c', 'src/scanner.c' },
        branch = 'master',
      },
    }

    -- Register templ filetype with treesitter
    vim.treesitter.language.register('templ', 'templ')
  end,
}
