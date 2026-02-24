return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme('catppuccin-mocha')
    vim.cmd.hi('Comment gui=none')

    -- Make background transparent
    -- NOTE: This requires a terminal emulator with transparency support enabled.
    -- If transparency doesn't work, check your terminal settings (e.g., iTerm2, Alacritty, Kitty).
    vim.cmd([[
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
    ]])
  end,
}
