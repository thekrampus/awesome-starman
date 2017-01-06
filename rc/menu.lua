-- Menu configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local util = require("rc.util")
local var = require("rc.variables")

local x_macros = require("extensions.x_macros")

local function spawn_htop()
   awful.spawn(var.terminal .. " -e htop")
end

local function spawn_dmesg()
   awful.spawn(var.terminal .. " -e dmesg -wH")
end

local function spawn_irc()
   awful.spawn("chromium --app=https://riot.im/app")
   awful.spawn(var.terminal .. " -e irssi --config=/home/rob/.irssi/sudonet.conf")
end

local function spawn_loadout()
   spawn_irc()

   spawn_htop()
   spawn_dmesg()
end


-- awesome WM Menu
local awesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "edit config", var.editor_cmd .. " " .. awesome.conffile },
   { "check config", function() util.run_and_notify({cmd="awesome -k", notify=true}) end},
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
                             { "open terminal", var.terminal } }
                       })

-- Menubar configuration
menubar.utils.terminal = var.terminal -- Set the terminal for applications that require it

return mymainmenu
