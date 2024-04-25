return {
  "nvim-tree/nvim-tree.lua",
  opts = {
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
  },
  config = function(_, opts)
    local nvimtree = require("nvim-tree")
    nvimtree.setup(opts)
  end,
}
