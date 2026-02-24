local wezterm = require('wezterm')
local url = require('url')
local mwindow = require('window')
local mappings = require('keys')
local mouse_bindings = require('mouse_bindings')
local session_manager = require('plugins.session-manager')

local config = wezterm.config_builder()
local is_linux = wezterm.target_triple == 'x86_64-unknown-linux-gnu'
local is_osx = wezterm.target_triple == 'aarch64-apple-darwin'

config.unix_domains = { { name = 'unix' } }
config.default_gui_startup_args = { 'connect', 'unix' }
config.color_scheme = 'Catppuccin Mocha'

if is_linux then
  -- local cursor = require('cursor')
  config.default_prog = { 'bash', '--login' }
  config.font_size = 16
  config.default_cursor_style = 'SteadyBlock'
  config.set_environment_variables = {
    XDG_CONFIG_HOME = '/home/' .. (os.getenv('USERNAME') or os.getenv('USER')) .. '/.config',
    XDG_DATA_HOME = '/home/' .. (os.getenv('USERNAME') or os.getenv('USER')) .. '/.local/share',
  }
end

if is_osx then
  config.default_prog = { '/opt/homebrew/bin/bash', '--login' }
  config.set_environment_variables = {
    XDG_CONFIG_HOME = '/Users/' .. (os.getenv('USERNAME') or os.getenv('USER')) .. '/.config',
    XDG_DATA_HOME = '/Users/' .. (os.getenv('USERNAME') or os.getenv('USER')) .. '/.local/share',
    HOMEBREW_PREFIX = '/opt/homebrew',
  }
end

url.apply(config)
mwindow.apply(config)
mappings.apply(config)
mouse_bindings.apply(config)

require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()
require('events.window-resized').setup()
require('events.open-uri').setup()

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

wezterm.on('gui-startup', function(cmd)
  local _, pane, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  if not is_linux then
    gui_window:perform_action(wezterm.action.ToggleFullScreen, pane)
  else
    gui_window:maximize()
  end
end)

return config
