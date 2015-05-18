-- A dbus-based spotify widget for awesome
local music_box_width = 30
local play_box_period = 0.2
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local music_box = {}
local play_box = {}
local play_timer = {}
local awesify = {}

local play_animation = {'⣸', '⣴', '⣦', '⣇', '⡏', '⠟', '⠻', '⢹'}
local music_playing = false
local play_anim_len = 8
local stop_sym = '⣿'
local play_index = 1

function awesify.create_playbox()
   play_box = wibox.widget.textbox()
   play_box:set_markup("<span color=\"white\">⣏</span>")

   play_timer = timer({timeout = play_box_period})
   play_timer:connect_signal("timeout", function()
                                play_index = (play_index % play_anim_len) + 1
                                play_box:set_markup("<span color=\"white\">" .. play_animation[play_index] .. "</span>")
                                music_playing = true
   end)
   
   return play_box
end

function awesify.create_musicbox()
   music_box = wibox.widget.textbox()
   music_box:set_text("⣹")
   
   return music_box
end

function awesify.update_music(data, appname, replaces_id, icon, track, album, actions, hints, expire)
   local safe_track = string.gsub(track, "&", "+")
   local safe_album = string.gsub(album, "&", "+")
   music_box:set_markup(safe_track .. " <span color=\"white\">" .. safe_album .. "</span>")
   play_timer:start()
   
   return false
end

function awesify.playpause()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")

   if music_playing then
      play_timer:stop()
      music_playing = false
      play_box:set_markup("<span color=\"white\">" .. stop_sym .. "</span>")
   else
      play_timer:start()
   end
end

function awesify.next()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
end

function awesify.previous()
   awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
end

return awesify
