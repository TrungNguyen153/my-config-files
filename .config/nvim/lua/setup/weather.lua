return {
  setup = function()
    require('weather').setup({
      openweathermap = {
        app_id = {
          var_name = 'WEATHER_TOKEN',
          value = "a57b34af5b468f3e3e914883cf0c6cec", -- https://home.openweathermap.org/api_keys
        },
      },
      weather_icons = require('weather.other_icons').nerd_font,
    })
    require('weather.notify').start(70, 'info')
  end,
  status_line = function()
    return require('weather.lualine').default_c({})
  end,
}
