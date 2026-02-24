# LSP Configuration Structure

This directory contains modularized LSP configuration.

## Structure

```
config/
├── filetypes.lua         # Filetype detection and autocommands
└── lsp/
    ├── keymaps.lua       # LSP keybindings
    ├── highlight.lua     # Document highlight on CursorHold
    └── servers.lua       # LSP server configurations
```

## Files

### `filetypes.lua`
Handles filetype detection for:
- Terraform/HCL files (*.tf, *.hcl, *.tfvars, etc.)
- Jenkins files (Jenkinsfile*)
- Yank highlight autocmd

### `lsp/keymaps.lua`
LSP keybindings that activate on LspAttach:
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `gD` - Go to declaration
- `K` - Hover documentation
- `<leader>rn` - Rename
- `<leader>ca` - Code action
- `<leader>ds` - Document symbols
- `<leader>ws` - Workspace symbols
- `<leader>th` - Toggle inlay hints

### `lsp/highlight.lua`
Configures document highlight (highlights symbol under cursor):
- Triggers on CursorHold/CursorHoldI
- Clears on CursorMoved/CursorMovedI
- Auto-cleans up on LspDetach

### `lsp/servers.lua`
LSP server configurations. Add your servers here:
```lua
return {
  lua_ls = { settings = {...} },
  bashls = {},
  terraformls = {},
  -- etc.
}
```

## Adding New LSP Servers

1. Edit `config/lsp/servers.lua`
2. Add your server to the table:
   ```lua
   your_server = {
     settings = {
       -- server-specific settings
     },
   },
   ```
3. Mason will auto-install it on next Neovim start
