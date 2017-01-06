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
                    raise = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                    titlebars_enabled = false
     }
   },
   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
        },
        class = {
           "Arandr",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Wpa_gui",
           "pinentry",
           "veromix",
           "xtightvncviewer",
           "gvncviewer",
           "sun-awt-X11-XFramePeer"},

        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true } },
   -- Clients which should be on the primary screen
   { rule_any = {
        name = {
           "irssi"
        },
        instance = {
           "riot.im__app"
        }
   }, properties = { screen = 1 } },
   -- Clients which should be on the auxillary screen
   { rule_any = {
        class = {
           "gimp",
           "Spotify",
           "Steam"
        }
   }, properties = { screen = auxm } },
   { rule = { name = "irssi" },
     properties = { tag = 2 } },
   { rule = { instance = "riot.im__app" },
     properties = { tag = 2 } },
   { rule = { class = "Spotify" },
     properties = { tag = 4 } },
   { rule = { class = "Steam" },
     properties = { tag = 5 } }
}
-- }}}


-- {{{ Naughty
-- Suppress default notifications
naughty.config.presets.spotify = {callback = function() return false end}
table.insert(naughty.dbus.config.mapping, {{appname = "Spotify"}, naughty.config.presets.spotify})
-- }}}
