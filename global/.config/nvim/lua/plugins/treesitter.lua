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
      'templ',
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

    -- Enable treesitter highlighting and indentation for all filetypes.
    -- In nvim-treesitter main, these are no longer auto-enabled;
    -- they must be wired up via FileType autocommands (Neovim 0.12+).
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

    -- Use the hcl parser for all terraform filetypes (terraform is a superset
    -- of HCL; a dedicated terraform parser ships with nvim-treesitter but has
    -- no highlight queries, whereas hcl does).
    for _, ft in ipairs({ 'terraform', 'terraform-vars', 'terraform-stack', 'terraform-deploy' }) do
      vim.treesitter.language.register('hcl', ft)
    end
  end,
}
