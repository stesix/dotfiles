local wezterm = require('wezterm')
local url = require('url')
local mwindow = require('window')
local mappings = require('keys')
local session_manager = require('plugins.session-manager')
-- local resurrect = require('plugins.resurrect')

local config = wezterm.config_builder()
local is_linux = wezterm.target_triple == 'x86_64-unknown-linux-gnu'
local is_osx = wezterm.target_triple == 'aarch64-apple-darwin'

config.unix_domains = { { name = 'unix' } }
config.default_gui_startup_args = { 'connect', 'unix' }
config.default_prog = { '/opt/homebrew/bin/bash', '--login' }
config.color_scheme = 'Catppuccin Mocha'

if is_osx then
  config.set_environment_variables = {
    XDG_CONFIG_HOME = '/Users/' .. (os.getenv('USERNAME') or os.getenv('USER')) .. '/.config',
    HOMEBREW_PREFIX = '/opt/homebrew',
  }
end

url.apply(config)
mwindow.apply(config)
mappings.apply(config)
-- resurrect.apply(config)

require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()
require('events.window-resized').setup()

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')
smart_splits.apply_to_config(config, {
  direction_keys = { 'h', 'j', 'k', 'l' },
  modifiers = {
    move = 'CTRL',
    resize = 'ALT',
  },
})

wezterm.on('save_session', function(window)
  session_manager.save_state(window)
end)

wezterm.on('load_session', function(window)
  session_manager.load_state(window)
end)
wezterm.on('restore_session', function(window)
  session_manager.restore_state(window)
end)

wezterm.on('gui-startup', function()
  local _, _, window = wezterm.mux.spawn_window({})
  window:gui_window():maximize()
end)

return config
