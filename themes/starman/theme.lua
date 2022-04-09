-----------------------------------
--    "Starman" awesome theme    --
--          By krampus           --
-- Based on Zenburn by Adrian C. --
-----------------------------------

-- required by the theme
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local lain  = require("lain")
local pretty = require("pl.pretty")

local xresources = require("beautiful.xresources")
local xrdb       = xresources.get_current_theme()
local dpi        = xresources.apply_dpi

local jammin = require("jammin")

-- {{{ Palette
local bg = {
   default = xrdb.background,
   black = xrdb.color0,
   red = xrdb.color1,
   green = xrdb.color2,
   yellow = xrdb.color3,
   blue = xrdb.color4,
   brown = xrdb.color5,
   cyan = xrdb.color6,
   white = xrdb.color7,
}
local fg = {
   default = xrdb.foreground,
   black = xrdb.color8,
   red = xrdb.color9,
   green = xrdb.color10,
   yellow = xrdb.color11,
   blue = xrdb.color12,
   brown = xrdb.color13,
   cyan = xrdb.color14,
   white = xrdb.color15,
}
-- }}}

-- {{{ Main
local theme     = {}
theme.name      = "starman"
local theme_dir = awful.util.get_configuration_dir() .. "/themes/" .. theme.name
theme.font      = "lemon,WenQuanYi,profont 10px"
theme.icon_font = "typicons 15px"
-- }}}

-- {{{ Wallpaper
function theme.wallpaper(s)
   local size = s.geometry.width * s.geometry.height
   if size <= 1280 * 1024 then
      return theme_dir .. "/starman-background-3-small.png"
   elseif size <= 1920 * 1080 then
      return theme_dir .. "/starman-background-5.png"
   else
      return theme_dir .. "/starman-background-5-big.png"
   end
end
-- }}}

-- {{{ Colors
theme.fg_normal  = fg.default
theme.fg_focus   = bg.white
theme.fg_urgent  = fg.white
theme.bg_normal  = bg.default
theme.bg_focus   = bg.black
theme.bg_urgent  = bg.white
theme.bg_systray = bg.default
-- }}}

-- {{{ Borders
theme.border_width  = dpi(2)
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_focus
theme.border_marked = theme.bg_urgent

-- Smart borders
-- Color for smart border on focused client
theme.border_smart  = theme.fg_urgent
-- Size of gap between client and corner arrow
theme.border_gutter = dpi(4)
-- Weight of corner arrow
theme.border_weight = dpi(2)
-- Weight of side strings
theme.border_string = 0
-- Size of corner arrow
theme.border_arrow  = dpi(16)
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = theme.bg_focus
theme.titlebar_bg_normal = theme.bg_normal
-- }}}

-- {{{ Tags
theme.gap_single_client  = true
theme.useless_gap        = dpi(15)
theme.master_fill_policy = "expand"
-- }}}

-- {{{ Taglist & Tasklist
theme.taglist_bg_focus       = theme.fg_normal
theme.taglist_bg_occupied    = theme.bg_focus
theme.taglist_bg_volatile    = fg.red
theme.taglist_fg_volatile    = bg.red
theme.taglist_shape          = gears.shape.powerline
theme.taglist_shape_volatile = gears.shape.hexagon
theme.tasklist_shape         = gears.shape.powerline

theme.taglist_spacing        = -6
theme.tasklist_spacing       = -6
-- }}}

-- {{{ Menu
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Misc
theme.awesome_icon               = theme_dir .. "/awesome-icon.png"
theme.notify_icon_size_max       = dpi(32)
-- }}}

-- {{{ Layout
theme.layout_tile       = theme_dir .. "/layouts/tile.png"
theme.layout_tileleft   = theme_dir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme_dir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme_dir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme_dir .. "/layouts/fairv.png"
theme.layout_fairh      = theme_dir .. "/layouts/fairh.png"
theme.layout_spiral     = theme_dir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme_dir .. "/layouts/dwindle.png"
theme.layout_max        = theme_dir .. "/layouts/max.png"
theme.layout_fullscreen = theme_dir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme_dir .. "/layouts/magnifier.png"
theme.layout_floating   = theme_dir .. "/layouts/floating.png"
theme.layout_cornernw   = theme_dir .. "/layouts/cornernw.png"
theme.layout_cornerne   = theme_dir .. "/layouts/cornerne.png"
theme.layout_cornersw   = theme_dir .. "/layouts/cornersw.png"
theme.layout_cornerse   = theme_dir .. "/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus               = theme_dir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme_dir .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active        = theme_dir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme_dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme_dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme_dir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active       = theme_dir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme_dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme_dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme_dir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active     = theme_dir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme_dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme_dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme_dir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = theme_dir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme_dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme_dir .. "/titlebar/maximized_normal_inactive.png"
-- }}}

-- {{{ Widgets
local markup = lain.util.markup
local space = wibox.widget.textbox(' ')

local function bracket_widget(my_widget)
   return wibox.widget {
      wibox.widget.textbox('['),
      my_widget,
      wibox.widget.textbox(']'),
      layout = wibox.layout.fixed.horizontal
   }
end

local function make_preset()
   return {
      font = theme.font,
      fg = theme.fg_normal,
      bg = theme.bg_normal
   }
end

local function colorize(text, color)
   return string.format("<span color=\"%s\">%s</span>", color, text)
end

local function color_level(colors, default_color)
   return function(levels)
      return function(data)
         for i, level in ipairs(levels) do
            if data >= level then
               return colors[i]
            end
         end
         return default_color
      end
   end
end
local color_level_danger = color_level({fg.red, fg.yellow, fg.white}, fg.default)

-- Time & Date
local clock = awful.widget.watch(
   "date +'%a %b %d %R'", 60,
   function(widget, stdout)
      widget:set_markup(" " .. markup.font(theme.font, stdout))
   end
)

theme.cal = lain.widget.cal({
      attach_to = { clock },
      notification_preset = make_preset()
})

-- Filesystem
local filesystem = lain.widget.fs({
      notification_preset = make_preset(),
      settings = function()
         widget:set_markup(markup.font(theme.font, fs_now["/"].percentage .. "%"))
      end
})

-- Memory
local swap_total = 8192
local memorybar = wibox.widget {
   forced_height    = dpi(1),
   forced_width     = dpi(59),
   color            = theme.fg_normal,
   background_color = theme.bg_normal,
   margins          = 1,
   paddings         = 1,
   ticks            = true,
   ticks_size       = dpi(6),
   widget           = wibox.widget.progressbar,
}
local swapbar = wibox.widget {
   forced_height    = dpi(1),
   forced_width     = dpi(29),
   color            = bg.red,
   background_color = theme.bg_normal,
   margins          = 1,
   paddings         = 1,
   ticks            = true,
   ticks_size       = dpi(6),
   widget           = wibox.widget.progressbar,
}
local memory_color = color_level_danger({90, 75, 50})
lain.widget.mem({
      settings = function()
         memorybar:set_color(memory_color(mem_now.perc))
         memorybar:set_value(mem_now.perc / 100)

         swap_perc = tonumber(mem_now.swapused) / swap_total
         swapbar:set_value(swap_perc / 100)
      end
})
local memory = wibox.widget {
   wibox.container.margin(
      wibox.container.background(memorybar, bg.white, gears.shape.rectangle),
      dpi(1), dpi(1),
      dpi(3), dpi(3)
   ),
   wibox.container.margin(
      wibox.container.background(swapbar, bg.white, gears.shape.rectangle),
      0, dpi(1),
      dpi(3), dpi(3)
   ),
   layout = wibox.layout.fixed.horizontal
}

-- CPU & core temperature
local cpu_count = 8
local cpubox = wibox.widget {
   layout = wibox.layout.fixed.horizontal
}
local cpubars = {}
for i=1,cpu_count do
   cpubars[i] = wibox.widget {
      background_color = theme.bg_normal,
      margins = { top=dpi(1) },
      widget = wibox.widget.progressbar
   }
   cpubox:add(
      wibox.widget {
         cpubars[i],
         forced_width = 3,
         direction = 'east',
         layout = wibox.container.rotate
      }
   )
end
local cpu_colors = color_level_danger({98, 75, 50})
lain.widget.cpu({
      settings = function()
         for i=1,cpu_count do
            cpubars[i]:set_color(cpu_colors(cpu_now[i].usage))
            cpubars[i]:set_value(cpu_now[i].usage / 100)
         end
      end
})
local coretemp_colors = color_level_danger({100, 80, 50})
local coretemp = lain.widget.temp({
      tempfile = "/sys/devices/virtual/thermal/thermal_zone2/temp",
      settings = function()
         local color = coretemp_colors(coretemp_now)
         widget:set_markup(
            markup.font(
               theme.font,
               colorize(coretemp_now .. "°C", color)
            )
         )
      end
})
local cpuinfo = wibox.widget {
   coretemp,
   wibox.container.margin(
      cpubox,
      0, 0,
      dpi(4), dpi(4)
   ),
   layout = wibox.layout.fixed.horizontal
}

-- Weather
local api_key_path = "/home/rob/.openweather.key"
-- synchronously read key (only done once on load)
local openweather_api_key = ""
local f = io.open(api_key_path, "r")
if f ~= nil then
   openweather_api_key = f:read("*line")
end

local temperature_color = color_level(
   {bg.red, fg.red, bg.yellow, fg.yellow, fg.cyan, bg.cyan, fg.blue}, fg.white
)(
   {100, 90, 85, 75, 65, 50, 32}
 )

-- https://openweathermap.org/weather-conditions
-- https://fontello.github.io/typicons.font/demo.html
local _weather_icon_map = {
   -- day
   ["01d"] = "\u{e142}", -- clear sky
   ["02d"] = "\u{e13e}", -- few clouds
   ["03d"] = "\u{e13b}", -- scattered clouds
   ["04d"] = "\u{e143}", -- broken clouds
   ["09d"] = "\u{e13f}", -- shower rain
   ["10d"] = "\u{e13c}", -- rain
   ["11d"] = "\u{e141}", -- thunderstorm
   ["13d"] = "\u{e140}", -- snow
   ["50d"] = "\u{e144}", -- mist
   -- night
   ["01n"] = "\u{e13d}", -- clear sky
   ["02n"] = "\u{e13e}", -- few clouds
   ["03n"] = "\u{e13b}", -- scattered clouds
   ["04n"] = "\u{e143}", -- broken clouds
   ["09n"] = "\u{e13f}", -- shower rain
   ["10n"] = "\u{e13c}", -- rain
   ["11n"] = "\u{e141}", -- thunderstorm
   ["13n"] = "\u{e140}", -- snow
   ["50n"] = "\u{e144}", -- mist
}


local function weather_icon(icon)
   return _weather_icon_map[icon] or "\u{e137}"
end

local function _wind_description(speed_mph)
   -- Find adjective to describe winds by speed
   -- see https://en.wikipedia.org/wiki/Beaufort_scale
   if speed_mph >= 73 then
      return "hurricane-force winds"
   elseif speed_mph >= 64 then
      return "violent storm winds"
   elseif speed_mph >= 55 then
      return "storm-force winds"
   elseif speed_mph >= 47 then
      return "severe gale winds"
   elseif speed_mph >= 39 then
      return "gale-force winds"
   elseif speed_mph >= 32 then
      return "high winds"
   elseif speed_mph >= 25 then
      return "a strong breeze"
   elseif speed_mph >= 19 then
      return "a fresh breeze"
   elseif speed_mph >= 13 then
      return "a moderate breeze"
   elseif speed_mph >= 8 then
      return "a gentle breeze"
   elseif speed_mph >= 4 then
      return "a light breeze"
   elseif speed_mph >= 1 then
      return "light air"
   else
      return "calm air"
   end
end

local function weather_notification_fun(report)
   -- Build a human-readable weather report

   -- Start with the day and hour
   local ret = string.format("%16s: ", os.date('%A, %I%p', report['dt']))

   -- Add colorized temperature
   local temp = math.floor(report['main']['temp'])
   ret = ret .. colorize(temp .. "°F", temperature_color(temp)) .. ", with "

   -- Build list of weather conditions
   local cond = {}
   for i=1,#report['weather'] do
      table.insert(cond, report['weather'][i]['description'])
   end
   if report['rain'] ~= nil then
      table.insert(cond, string.format("%.2fmm of rain", report['rain']['3h']))
   end
   if report['snow'] ~= nil then
      table.insert(cond, string.format("%.2fmm of snow", report['snow']['3h']))
   end
   if report['wind'] ~= nil then
      table.insert(cond, _wind_description(report['wind']['speed']))
   end

   -- Format list of conditions in english grammar
   if #cond == 1 then
      ret = ret .. cond[1]
   elseif #cond == 2 then
      ret = ret .. cond[1] .. " and " .. cond[2]
   else
      for i=1,#cond-1 do
         ret = ret .. cond[i] .. ", "
      end
      ret = ret .. "and " .. cond[#cond]
   end

   return ret .. "."
end

local weather_report = lain.widget.weather({
      -- 5-day forecast (free)
      forecast_call = "curl -s 'http://api.openweathermap.org/data/2.5/forecast?id=%s&units=%s&lang=%s&APPID=%s'",
      APPID = openweather_api_key,
      city_id = 5454711,  -- Albuquerque, NM
      units = "imperial",
      lang = "en",
      cnt = 40,
      notification_preset = make_preset(),
      notification_text_fun = weather_notification_fun,
      settings = function()
         local temp = math.floor(weather_now['main']['temp'])
         local symbol = ""
         for i=1,#weather_now['weather'] do
            symbol = symbol .. weather_icon(weather_now['weather'][i]['icon'])
         end
         widget:set_markup(
            markup.font(
               theme.icon_font,
               colorize(symbol, temperature_color(temp))
            )
         )

         -- -- Symbol render test
         -- local _test_string = ""
         -- for _,v in pairs(_weather_icon_map) do
         --    _test_string = _test_string .. v
         -- end
         -- widget:set_markup(
         --    markup.font(
         --       theme.icon_font,
         --       _test_string
         --    )
         -- )

         -- -- Temperature color test
         -- local ret = ""
         -- for i=1,11 do
         --    local t = i * 10
         --    ret = ret .. colorize(t, temperature_color(t)) .. " "
         -- end
         -- widget:set_markup(markup.font(theme.font, ret))

      end
})


-- Media
local music_glyph = wibox.widget.textbox("\u{23f9}")
local music_status = wibox.widget {
   wibox.widget {
      music_glyph,
      valign="center",
      halign="center",
      forced_height = 16,
      forced_width = 16,
      widget = wibox.container.place
   },
   widget = wibox.container.arcchart,
   paddings = {
      top = 2,
      bottom = 0,
      left = 0,
      right = 0
   },
   value = 1,
   max_value = 1,
   border_color = fg.black,
   colors = {fg.white},
   border_width = 0,
   thickness = 1.5,
   forced_width = 16,
   forced_height = 16,
   start_angle = math.pi
}

local function music_animate()
   music_status.start_angle = (music_status.start_angle - 0.3927) % (2 * math.pi)
   return true
end
music_status.timer = gears.timer{
   timeout = 0.333,
   callback = music_animate
}

local function music_status_start()
   music_status.value = 0.5
   music_status.timer:again()
end

local function music_status_stop()
   music_status.value = 1
   if music_status.timer.started then
      music_status.timer:stop()
   end
end

local music_update = jammin {
   tooltip_preset = awful.util.table.join(make_preset(), {delay_show = 2}),
   playback_handler = function(self, status)
      if status == "Paused" then
         music_glyph:set_markup(markup.font("typicons 12px", colorize("\u{e0ac}", "white")))
         music_status_stop()
      elseif status == "Playing" then
         music_glyph:set_markup(markup.font("typicons 12px", colorize("\u{e0b0}", "white")))
         music_status_start()
      else  -- "Stopped" or otherwise
         music_glyph:set_markup(markup.font("typicons 12px", colorize("\u{e0b6}", "white")))
         music_status_stop()
      end
   end,
   track_handler = function(self, data)
      local artist = table.concat(data.artists, ", ")
      self.widget:set_markup(
         markup.font(
            theme.font,
            string.format(
               "%s " .. colorize("%s", fg.white),
               data.title, artist
            )
         )
      )

      -- local ttip_text = string.format("%s - %s\nfrom " .. colorize("%s", fg.white),
      -- data.title, artist, data.album)
      -- if data.created.year ~= nil then
      --    ttip_text = ttip_text .. string.format(" (%s)", data.created.year)
      -- end
      local ttip_text = pretty.write(data)

      self.tooltip:set_markup(ttip_text)
   end
}
local music = wibox.widget {
   music_status,
   music_update.widget,
   layout = wibox.layout.fixed.horizontal
}
local volume_popup = jammin.volumebar {
   widget = music,
   bar_color = bg.white,
   handle_color = "[0]#000000",
   handle_border_color = fg.white,
   border_color = bg.black,
   border_width = dpi(2),
   background_color = bg.default
}

music:buttons(awful.util.table.join(
                 awful.button({ }, 1, function() jammin.playpause(nil) end ),
                 awful.button({ }, 2, jammin.mute),
                 awful.button({ }, 3, function() volume_popup:toggle() end ),
                 awful.button({ }, 4, jammin.vol_up ),
                 awful.button({ }, 5, jammin.vol_down )
))

-- -- Network Activity
-- local net_rate_down = wibox.widget.textbox("")
-- local net = lain.widget.net {
--    notify = "off",
--    eth_state = "on",
--    settings = function()
--    end
-- }

-- local netinfo =
-- }}}


function theme.at_screen_connect(s)
   local util = require("rc.util")
   local tags = require("rc.tags")
   local keys = require("rc.keys")

   -- Size a wallpaper to the screen
   gears.wallpaper.maximized(theme.wallpaper(s), s, true)

   -- Tags
   tags.add_tags_to_screen(s)

   -- Promptbox
   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   s.mylayoutbox = awful.widget.layoutbox(s)
   s.mylayoutbox:buttons(keys.layoutbox_buttons)

   -- Create patched layout for taglist
   local tag_layout = wibox.layout.fixed.horizontal()
   tag_layout.fit = util.fixed_fit

   -- Create a taglist widget
   s.mytaglist = awful.widget.taglist {
         screen = s,
         filter = awful.widget.taglist.filter.all,
         buttons = keys.taglist_buttons,
         update_function = util.icon_list_update,
         layout = tag_layout
   }


   -- Create a tasklist widget
   s.mytasklist = awful.widget.tasklist {
         screen = s,
         filter = awful.widget.tasklist.filter.currenttags,
         buttons = keys.tasklist_buttons
   }

   -- Different tray (right widgets) for primary screen
   if s == screen.primary then
      s.mytray = {
         music, space,
         -- volumewidget, space,
         bracket_widget(cpuinfo),
         memory,
         bracket_widget(filesystem),
         bracket_widget(weather_report),
         clock, space,
         s.mylayoutbox,
         layout = wibox.layout.fixed.horizontal
      }
   else
      s.mytray = {
         clock,
         space,
         s.mylayoutbox,
         layout = wibox.layout.fixed.horizontal
      }
   end

   -- Create the wibox
   s.mywibox = awful.wibar({
         screen = s,
         position = "top",
         height = dpi(15)
   })

   -- Populate the wibox with goodies
   s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      expand = "inside",
      { -- Left widgets
         layout = wibox.layout.fixed.horizontal,
         s.mytaglist,
         s.mypromptbox
      },
      s.mytasklist, -- Middle widget
      s.mytray -- Right widgets
   }
end

return theme
