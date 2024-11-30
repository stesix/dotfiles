local M = {}

function M.apply(config)
  config.window_decorations = 'RESIZE'
  config.window_background_opacity = 0.85
  config.macos_window_background_blur = 5
  config.enable_tab_bar = true
  config.audible_bell = 'Disabled'
  config.use_fancy_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
end

return M
