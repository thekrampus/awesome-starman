-- A dbus-based media widget for awesome
local awful = require("awful")
local wibox = require("wibox")
local timer = require("gears.timer")
local util = require("rc.util")

local awesify = {}
awesify.__index = awesify

-- local play_animation = {'⣸', '⣴', '⣦', '⣇', '⡏', '⠟', '⠻', '⢹'}; local play_box_period = 0.2; local pause_glyph = '⣿';
-- local play_animation = {'⢸', '⣰', '⣤', '⣆', '⡇', '⠏', '⠛', '⠹'}; local play_box_period = 0.2; local pause_glyph = '⣿';
-- local play_animation = {'⠁', '⠂', '⠄', '⡈', '⡐', '⡠', '⣁', '⣂', '⣌', '⣔', '⣥', '⣮', '⣷', '⣿', '⣶', '⣤', '⣀', ' '}; local play_box_period = 0.2; local pause_glyph = '⣿'
-- local play_animation = {'⣀', '⡠', '⡠', '⠔', '⠔', '⠔', '⠊', '⠊', '⠊', '⠊', '⠉', '⠉', '⠉', '⠉', '⠉', '⠉', '⠑', '⠑', '⠑', '⠑', '⠢', '⠢', '⠢', '⢄', '⢄'}; local play_box_period = 0.03; local pause_glyph = '⣀';
-- local play_animation = {' ⣸', '⢀⣰', '⣀⣠', '⣄⣀', '⣆⡀', '⣇ ', '⡏ ', '⠏⠁', '⠋⠉', '⠉⠙', '⠈⠹', ' ⢹'}; local play_box_period = 0.16; local pause_glyph = '⣿⣿';
local play_animation = {' ⡱', '⢀⡰', '⢄⡠', '⢆⡀', '⢎ ', '⠎⠁', '⠊⠑', '⠈⠱'}; local play_box_period = 0.16667; local pause_glyph = '⢾⡷';

local track_fmt = ' %s <span color="white">%s</span> '
local tooltip_fmt = '   %s\n' ..
   '<span color="white">by</span> %s\n' ..
   '<span color="white">on</span> %s\n' ..
   '   <span color="green">%s</span>'

local function make_menu()
   local theme = {width = 20,
                  height = 220}

   local menu = awful.menu{ theme = theme }

   local function menu_widget()
      local beautiful = require("beautiful")
      local gears = require("gears")

      local function handle_shape(cr, w, h)
         return gears.shape.partially_rounded_rect(cr, w, h, true, false, true, true, theme.width)
      end
      local slider = wibox.widget {
         bar_shape = gears.shape.rounded_bar,
         bar_height = 2,
         bar_color = beautiful.fg_focus,
         handle_color = "[0]#000000",
         handle_shape = handle_shape,
         handle_border_color = beautiful.fg_focus,
         handle_border_width = 2,
         handle_width = theme.width,
         handle_margins = {left=4, right=4, top=4, bottom=4},
         value = 100,
         widget = wibox.widget.slider
      }

      local function slider_callback()
         awesify.vol_set(slider.value)
      end

      slider:connect_signal("widget::redraw_needed", slider_callback)

      local w = wibox.container {
         slider,
         direction = 'east',
         widget = wibox.container.rotate
      }
      return {akey = nil,
              widget = w,
              cmd = nil}
   end

   menu:add({ new = menu_widget })

   return menu
end

function awesify.playpause()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
end

function awesify.next()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
end

function awesify.previous()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
end

function awesify.vol_set(n)
   awful.spawn("amixer set Master " .. n .. "%")
end

function awesify.vol_up()
   awful.spawn("amixer set Master 5%+")
end

function awesify.vol_down()
   awful.spawn("amixer set Master 5%-")
end

function awesify.mute()
   awful.spawn("amixer set Master playback toggle")
end

function awesify:set_track_info()
   if self.track then
      self.music_box:set_markup(string.format(track_fmt,
                                              self.track.title,
                                              self.track.artist))
      self.tooltip:set_markup(string.format(tooltip_fmt,
                                            self.track.title,
                                            self.track.artist,
                                            self.track.album,
                                            self.track.year))
   else
      self.music_box:set_text("⣹")
      self.tooltip:set_markup("... nothing's playing...")
   end
end

--- Handler function for PlaybackStatus change signals
-- Updates the playbox animation to reflect the playback status
function awesify:handle_playback(status)
   if status == "Paused" then
      self.play_timer:stop()
      self.play_box:set_markup("<span color=\"white\">" .. pause_glyph .. "</span>")
   elseif status == "Stopped" then
      self.play_timer:stop()
      self.play_box:set_markup("<span color=\"white\">⣏</span>")
      self.track = nil
   elseif status == "Playing" then
      self.play_timer:again()
   end
end

--- Handler function for Metadata change signals
-- Updates the musicbox to reflect the new track
function awesify:handle_trackchange(metadata)
   local nfields = 0
   for _ in pairs(metadata) do
      nfields = nfields + 1
   end
   if nfields == 0 then
      -- Empty metadata indicates that spotify has been closed
      self.track = nil
   else
      self.track = {}
      -- Parse and sanitize the data to print
      local title = metadata["xesam:title"] or ""
      self.track.title = util.sanitize(title)
      local artist_list = metadata["xesam:artist"] or ""
      self.track.artist = util.sanitize(table.concat(artist_list, ", "))
      local album = metadata["xesam:album"] or ""
      self.track.album = util.sanitize(album)
      local date = metadata["xesam:contentCreated"] or ""
      self.track.year = date:match("^(%d*)-") or "----"
   end
end

--- General handler function, callback on org.freedesktop.DBus.Properties
function awesify:on_signal(data, interface, changed, invalidated)
   if data.member == "PropertiesChanged" then
      if interface == "org.mpris.MediaPlayer2.Player" then
         if changed.PlaybackStatus ~= nil then
            -- Track play/pause/stop signal
            self:handle_playback(changed.PlaybackStatus)
         end
         if changed.Metadata ~= nil then
            -- Track change signal
            self:handle_trackchange(changed.Metadata)
         end
         self:set_track_info()
      end
   end
end

function awesify.new()
   local self = setmetatable({}, awesify)

   self.track = nil

   self.menu = make_menu()

   self.play_index = 1
   self.music_box = wibox.widget.textbox()

   self.play_box = wibox.widget.textbox()

   local w = wibox.layout.fixed.horizontal(self.play_box, self.music_box)

   self.tooltip = awful.tooltip{objects = {w}, delay_show = 1}

   local function animate()
      self.play_index = (self.play_index % #play_animation) + 1
      self.play_box:set_markup("<span color=\"white\">" .. play_animation[self.play_index] .. "</span>")
      return true
   end

   self.play_timer = timer.start_new(play_box_period, animate)
   self:handle_playback("Stopped")
   self:set_track_info()

   -- Hook into DBus signals
   dbus.add_match("session", "interface='org.freedesktop.DBus.Properties'")
   dbus.connect_signal("org.freedesktop.DBus.Properties", function(...) self:on_signal(...) end)

   w:buttons(awful.util.table.join(
                awful.button({ }, 1, awesify.playpause ),
                awful.button({ }, 2, awesify.mute),
                awful.button({ }, 3, function() self.menu:toggle() end ),
                awful.button({ }, 4, awesify.vol_down ),
                awful.button({ }, 5, awesify.vol_up )
   ))

   return w
end

setmetatable(awesify, {
                __call = function(cls, ...)
                   return cls.new(...)
                end
})

return awesify
