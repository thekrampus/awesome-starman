-- Rule & Preset configuration (called from rc.lua)
local awful     = require("awful")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local keys      = require("rc.keys")
local var       = require("rc.variables")

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width      = beautiful.border_width,
                    border_color      = beautiful.border_normal,
                    focus             = awful.client.focus.filter,
                    raise             = true,
                    keys              = keys.clientkeys,
                    buttons           = keys.clientbuttons,
                    screen            = awful.screen.preferred,
                    placement         = awful.placement.no_overlap+awful.placement.no_offscreen,
                    titlebars_enabled = var.titlebars_enabled
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
           "sun-awt-X11-XFramePeer",
           "keepassx"
        },
        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           -- "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true } },
   -- Clients which should not honor size hints
   { rule_any = {
        class = {
           "URxvt",
           "keepassx"
        }
   },
     properties = { size_hints_honor = false} },
   -- Clients which should be on the primary screen
   { rule_any = {
        name = {
           "irssi"
        },
        instance = {
           "riot.im__app"
        }
   }, properties = { screen = screen.primary } },
   -- Clients which should be on the auxillary screen
   { rule_any = {
        class = {
           "gimp",
           "Spotify",
           "Steam"
        }
   }, properties = { screen = var.auxm } },
   -- Clients which should be on the "misc" tag
   { rule_any = {
        name = {
           "dmesg",
           "htop"
        }
   }, properties = { tag = "misc" } },
   { rule = { name = "irssi" },
     properties = { tag = "chat" } },
   { rule = { instance = "riot.im__app" },
     properties = { tag = "chat" } },
   { rule = { class = "Spotify" },
     properties = { tag = "jams" } },
   { rule = { class = "Steam", name = "Steam" },
     properties = { tag = "game" } },
   { rule = { class = "Steam", name = "Friends" },
     properties = { tag = "chat" } },
   { rule = { class = "Steam", name = ".- %- Chat" },
     properties = { tag = "chat" } },
   { rule = { class = "keepassx" },
     properties = {
        sticky = true,
        width = 260,
        height = 300,
        honor_padding = false,
        honor_workarea = false,
        placement = function(...) awful.placement.centered(...) end
     }
   }
}
-- }}}

-- local util = require("nifty.util")

-- {{{ Naughty notification config
naughty.config.notify_callback = function(args)
   -- if args.title ~= "meta" then
   --    naughty.notify{title="meta", text=util.tcat(args), timeout=0}
   -- end
   args.icon_size = math.min(args.icon_size or 32, beautiful.notify_icon_size_max or 32)
   return args
end

-- }}}
