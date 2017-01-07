-- A dbus-based spotify widget for awesome
-- local capi = { screen = screen, awesome = awesome, dbus = dbus }
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

function awesify.playpause()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
end

function awesify.next()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
end

function awesify.previous()
   awful.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
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
      self.music_box:set_text("⣹")
   else
      -- Parse and sanitize the data to print
      local title = metadata["xesam:title"] or ""
      local safe_title = util.sanitize(title)
      local artist_list = metadata["xesam:artist"] or ""
      local safe_artist = util.sanitize(table.concat(artist_list, ", "))

      self.music_box:set_markup(" " .. safe_title .. " <span color=\"white\">" .. safe_artist .. "</span> ")

      -- Track change implies that a track is playing...
      self.handle_playback("Playing")
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
      end
   end
end

function awesify.new()
   local self = setmetatable({}, awesify)
   self.play_index = 1
   self.music_box = wibox.widget.textbox()
   self.music_box:set_text("⣹")

   self.play_box = wibox.widget.textbox()
   local function animate()
      self.play_index = (self.play_index % #play_animation) + 1
      self.play_box:set_markup("<span color=\"white\">" .. play_animation[self.play_index] .. "</span>")
      return true
   end

   self.play_timer = timer.start_new(play_box_period, animate)
   self:handle_playback("Stopped")

   -- Hook into DBus signals
   dbus.add_match("session", "interface='org.freedesktop.DBus.Properties'")
   dbus.connect_signal("org.freedesktop.DBus.Properties", function(...) self:on_signal(...) end)

   local w = wibox.layout.fixed.horizontal(self.play_box, self.music_box)
   return w
end

setmetatable(awesify, {
                __call = function(cls, ...)
                   return cls.new(...)
                end
})

return awesify
