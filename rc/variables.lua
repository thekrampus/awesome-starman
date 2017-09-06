-- Global variable settings (called from rc.lua)
local awful = require("awful")

local variables = {}

-- Load personal settings, falling back to an empty table if no personal conf exists
local res, personal = pcall(require, "rc.personal")
if not res then personal = {} end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
variables.modkey = personal.modkey or "Mod4"

-- Name of the theme to use
variables.theme = personal.theme or "default"

-- The default terminal and editor to run.
variables.terminal = personal.terminal or "xterm"
variables.editor = personal.editor or os.getenv("EDITOR") or "nano"
variables.editor_cmd = personal.editor_cmd or variables.terminal .. " -e " .. variables.editor

-- User home directory
variables.home_dir = personal.home_dir or os.getenv("HOME")

-- Auxillary monitor ID (usually 2)
variables.auxm = personal.auxm or screen.count()

-- Enable titlebars?
variables.titlebars_enabled = personal.titlebars_enabled or false

-- Each element represents a tag: the name, optional icon, and optional default layout
variables.tags = personal.tags or { {"1"}, {"2"}, {"3"}, {"4"}, {"5"}, {"6"}, {"7"}, {"8"} }

-- Usable layouts.
variables.layouts = personal.layouts or {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   awful.layout.suit.corner.nw,
   awful.layout.suit.corner.ne,
   awful.layout.suit.corner.sw,
   awful.layout.suit.corner.se
}

-- Main menu
variables.mainmenu = personal.mainmenu or
   {
      { "open terminal", variables.terminal },
      { "edit config", variables.editor_cmd .. " " .. awesome.conffile },
      { "restart", awesome.restart },
      { "quit", function() awesome.quit() end }
   }

-- Personal key & button definitions
variables.globalkeys = personal.globalkeys or {}
variables.globalbuttons = personal.globalbuttons or {}
variables.clientkeys = personal.clientkeys or {}
variables.clientbuttons = personal.clientbuttons or {}
variables.taglist_buttons = personal.taglist_buttons or {}
variables.tasklist_buttons = personal.tasklist_buttons or {}

return variables
