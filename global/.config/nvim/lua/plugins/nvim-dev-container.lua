return {
  'esensar/nvim-dev-container',
  cmd = {
    'DevcontainerStart',
    'DevcontainerAttach',
    'DevcontainerExec',
    'DevcontainerStop',
    'DevcontainerStopAll',
    'DevcontainerRemoveAll',
    'DevcontainerLogs',
    'DevcontainerEditNearestConfig',
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('devcontainer').setup({
      attach_mounts = {
        neovim_config = {
          -- enables mounting local config to /root/.config/nvim in container
          enabled = false,
          options = { 'readonly' },
        },
        neovim_data = {
          -- enables mounting local data to /root/.local/share/nvim in container
          enabled = true,
          options = {},
        },

        -- Only useful if using neovim 0.8.0+
        neovim_state = {
          -- enables mounting local state to /root/.local/state/nvim in container
          enabled = true,
          options = {},
        },
      },
    })
  end,
}
