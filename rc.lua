-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             -- Make sure we don't go into an endless error loop
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = err })
                             in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/starman/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Auxillary monitor ID (usually 2)
auxm = screen.count()

globalkeys = {}
globalbuttons = {}
-- }}}

require("rc.util")
require("rc.tags")
require("rc.menu")
require("rc.wibox")
require("rc.client")
require("rc.rules")

-- {{{ Wallpaper
if beautiful.smallpaper then
   gears.wallpaper.maximized(beautiful.smallpaper, 1, true)
else
   gears.wallpaper.maximized(beautiful.wallpaper, 1, true)
end

if beautiful.wallpaper then
   for s = 2, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(globalkeys,
   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
   awful.key({ modkey, "Shift"   }, "Return",
      function ()
         -- Get PWD of focused client and spawn new terminal session there
         pid = string.gsub(awful.util.pread('pgrep -P ' .. math.floor(client.focus.pid)), '[\r\n]+$', '')
         pwd = string.gsub(awful.util.pread('readlink /proc/' .. pid .. '/cwd'), '[\r\n]+$', '')
         if string.len(pwd) > 0 then
            awful.util.spawn(terminal .. ' -cd "' .. pwd .. '"')
         end
   end),
   awful.key({ modkey, "Control" }, "r", awesome.restart),

   -- Print Screen
   awful.key({ }, "Print", function() awful.util.spawn("scrot -e 'mv $f ~/pics/screenshots/ 2>/dev/null'") end),

   awful.key({ modkey, "Shift"   }, "space",  conf_debug)
)

-- Set keys & buttons
root.keys(globalkeys)
root.buttons(globalbuttons)
-- }}}
