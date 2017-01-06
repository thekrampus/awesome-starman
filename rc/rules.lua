-- Rule & Preset configuration (called from rc.lua)
local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    size_hints_honor = false } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true,
                    tag = tags[auxm][1] } },
   { rule = { name = "irssi" },
     properties = { tag = tags[1][2] } },
   { rule = { instance = "riot.im__app" },
     properties = { tag = tags[1][2] } },
   { rule = { class = "Spotify" },
     properties = { tag = tags[auxm][4] } },
   { rule = { class = "Steam" },
     properties = { tag = tags[auxm][5] } },
   { rule = { class = "gvncviewer" },
     properties = { floating = true } },
   { rule = { instance = "sun-awt-X11-XFramePeer" },
     properties = { floating = true } }
}
-- }}}


-- {{{ Naughty
-- Suppress default notifications
naughty.config.presets.spotify = {callback = function() return false end}
table.insert(naughty.config.mapping, {{appname = "Spotify"}, naughty.config.presets.spotify})
-- }}}
