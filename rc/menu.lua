-- Menu configuration (called from rc.lua)
local awful = require("awful")
-- awful.menu = require("patch.menu")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local x_macros = require("extensions.x_macros")

local function spawn_htop()
   awful.spawn(terminal .. " -e htop")
end

local function spawn_dmesg()
   awful.spawn(terminal .. " -e dmesg -wH")
end

local function spawn_irc()
   awful.spawn("chromium --app=https://riot.im/app")
   awful.spawn(terminal .. " -e irssi --config=/home/rob/.irssi/sudonet.conf")
end

local function spawn_loadout()
   spawn_irc()

   spawn_htop()
   spawn_dmesg()
end


-- awesome WM Menu
local awesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "check config", function() run_and_notify({cmd="awesome -k", notify=true}) end},
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end }
}

-- x_macros extension menu
local macromenu = x_macros.build_menu()

-- Tools & Utilities
local toolmenu = {
   { "htop", spawn_htop },
   { "dmesg", spawn_dmesg },
   { "dropbox status", "/home/rob/Files/dropbox_notify.sh"},
   { "x_macros", macromenu }
}

-- Main Menu
local mymainmenu = awful.menu({ items = { { "awesome", awesomemenu, beautiful.awesome_icon },
                             { "tools", toolmenu },
                             { "spawn irc", spawn_irc },
                             { "spawn loadout", spawn_loadout },
                             { "open terminal", terminal } }
                       })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

globalkeys = awful.util.table.join(globalkeys,
                                   awful.key({ modkey,         }, "w", function() mymainmenu:show() end),
                                   awful.key({ modkey, "Shift" }, "e", x_macros.hot_macro),
                                   awful.key({ modkey,         }, "p", function() menubar.show() end)
)

globalbuttons = awful.util.table.join(globalbuttons,
                                      awful.button({ }, 3, function() mymainmenu:toggle() end)
)

return mymainmenu
