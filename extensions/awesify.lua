-- A dbus-based spotify widget for awesome
local capi = { screen = screen, awesome = awesome, dbus = dbus }
local timer = require("gears.timer")
local wibox = require("wibox")
local awful = require("awful")
local music_box = {}
local play_box = {}
local play_timer = {}
local awesify = {}

-- local play_animation = {'⣸', '⣴', '⣦', '⣇', '⡏', '⠟', '⠻', '⢹'}; local play_box_period = 0.2; local pause_glyph = '⣿';
-- local play_animation = {'⢸', '⣰', '⣤', '⣆', '⡇', '⠏', '⠛', '⠹'}; local play_box_period = 0.2; local pause_glyph = '⣿';
-- local play_animation = {'⠁', '⠂', '⠄', '⡈', '⡐', '⡠', '⣁', '⣂', '⣌', '⣔', '⣥', '⣮', '⣷', '⣿', '⣶', '⣤', '⣀', ' '}; local play_box_period = 0.2; local pause_glyph = '⣿'
-- local play_animation = {'⣀', '⡠', '⡠', '⠔', '⠔', '⠔', '⠊', '⠊', '⠊', '⠊', '⠉', '⠉', '⠉', '⠉', '⠉', '⠉', '⠑', '⠑', '⠑', '⠑', '⠢', '⠢', '⠢', '⢄', '⢄'}; local play_box_period = 0.03; local pause_glyph = '⣀';
-- local play_animation = {' ⣸', '⢀⣰', '⣀⣠', '⣄⣀', '⣆⡀', '⣇ ', '⡏ ', '⠏⠁', '⠋⠉', '⠉⠙', '⠈⠹', ' ⢹'}; local play_box_period = 0.16; local pause_glyph = '⣿⣿';
local play_animation = {' ⡱', '⢀⡰', '⢄⡠', '⢆⡀', '⢎ ', '⠎⠁', '⠊⠑', '⠈⠱'}; local play_box_period = 0.16667; local pause_glyph = '⢾⡷';
local play_index = 1

function awesify.create_playbox()
   play_box = wibox.widget.textbox()
   play_box:set_markup("<span color=\"white\">⣏</span>")

   local function animate()
      play_index = (play_index % #play_animation) + 1
      play_box:set_markup("<span color=\"white\">" .. play_animation[play_index] .. "</span>")
      return true
   end

   play_timer = timer.start_new(play_box_period, animate)

   return play_box
end

function awesify.create_musicbox()
   music_box = wibox.widget.textbox()
   music_box:set_text("⣹")

   return music_box
end

function awesify.playpause()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
end

function awesify.next()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
end

function awesify.previous()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
end

--- General handler function, callback on org.freedesktop.DBus.Properties
function awesify.on_signal(data, interface, changed, invalidated)
   if data.member == "PropertiesChanged" then
      if interface == "org.mpris.MediaPlayer2.Player" then
         if changed.PlaybackStatus ~= nil then
            -- Track play/pause/stop signal
            handle_playback(changed.PlaybackStatus)
         end
         if changed.Metadata ~= nil then
            -- Track change signal
            handle_trackchange(changed.Metadata)
         end
      end
   end
end

--- Handler function for PlaybackStatus change signals
-- Updates the playbox animation to reflect the playback status
function handle_playback(status)
   if status == "Paused" then
      play_timer:stop()
      play_box:set_markup("<span color=\"white\">" .. pause_glyph .. "</span>")
   elseif status == "Stopped" then
      play_timer:stop()
      play_box:set_markup("<span color=\"white\">⣏</span>")
   elseif status == "Playing" then
      play_timer:start()
   end
end

--- Handler function for Metadata change signals
-- Updates the musicbox to reflect the new track
function handle_trackchange(metadata)
   local nfields = 0
   for _ in pairs(metadata) do
      nfields = nfields + 1
   end
   if nfields == 0 then
      -- Empty metadata indicates that spotify has been closed
      music_box:set_text("⣹")
   else
      -- Parse and sanitize the data to print
      local title = metadata["xesam:title"] or ""
      local safe_title = wibox_sanitize(title)
      local artist_list = metadata["xesam:artist"] or ""
      local safe_artist = wibox_sanitize(table.concat(artist_list, ", "))

      music_box:set_markup(" " .. safe_title .. " <span color=\"white\">" .. safe_artist .. "</span> ")
   end
end

function wibox_sanitize(raw_string)
   raw_string = string.gsub(raw_string, "&", "&amp;")
   raw_string = string.gsub(raw_string, "<", "&lt;")
   raw_string = string.gsub(raw_string, ">", "&gt;")
   raw_string = string.gsub(raw_string, "'", "&apos;")
   raw_string = string.gsub(raw_string, "\"", "&quot;")
   return raw_string
end

-- Configure DBUS support
if capi.dbus then
   capi.dbus.add_match("session", "interface='org.freedesktop.DBus.Properties'")
   capi.dbus.connect_signal("org.freedesktop.DBus.Properties", awesify.on_signal)
end

return awesify
