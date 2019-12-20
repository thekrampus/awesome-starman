-- Keybindings & button mappings (called from rc.lua)
local awful         = require("awful")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local util          = require("rc.util")
local tags          = require("rc.tags")
local var           = require("rc.variables")
local menu      = require("rc.menu")
local jammin        = require("jammin")

local keys = {}

-- {{{ Variables
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = var.modkey
-- }}}

-- {{{ Global key bindings
keys.globalkeys = awful.util.table.join(
   awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
      {description="show help", group="awesome"}),
   awful.key({ modkey, "Shift"   }, "[",   awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key({ modkey, "Shift"   }, "]",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
      {description = "go back", group = "tag"}),

   awful.key({ modkey,           }, "Right",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ modkey,           }, "Left",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),
   awful.key({ modkey,           }, "w", function () menu.main:show() end,
      {description = "show main menu", group = "awesome"}),
   awful.key({ modkey, "Shift"   }, "w", function () menu.freedesktop:show() end,
      {description = "show freedesktop menu", group = "awesome"}),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ modkey,           }, "`", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
   awful.key({ modkey,           }, "/", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),
   awful.key({ modkey, "Control" }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      {description = "go back", group = "client"}),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.spawn(var.terminal) end,
      {description = "spawn terminal", group = "launcher"}),
   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
      {description = "increase master width factor", group = "layout"}),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
      {description = "decrease master width factor", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
      {description = "increase the number of columns", group = "layout"}),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
      {description = "decrease the number of columns", group = "layout"}),
   awful.key({ modkey,           }, "Tab", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "Tab", function () awful.layout.inc(-1)                end,
      {description = "select previous", group = "layout"}),

   awful.key({ modkey, "Control" }, "n",
      function ()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            client.focus = c
            c:raise()
         end
      end,
      {description = "restore minimized", group = "client"}),

   -- Prompt
   awful.key({ modkey },            "space",     function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}),

   awful.key({ modkey }, "x",
      function ()
         awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
         }
      end,
      {description = "lua execute prompt", group = "awesome"}),
   -- Menubar
   awful.key({ modkey }, "p", function() menubar.show() end,
      {description = "show the menubar", group = "launcher"}),

   -- Media controls
   awful.key({ modkey          }, "Home", jammin.playpause,
      {description = "play/pause media", group = "media"}),
   awful.key({ modkey          }, "Prior", jammin.next,
      {description = "next track", group = "media"}),
   awful.key({ modkey          }, "Insert", jammin.previous,
      {description = "previous track", group = "media"}),
   awful.key({ modkey, "Shift" }, "=", jammin.vol_up,
      {description = "volume++", group = "media"}),
   awful.key({ modkey, "Shift" }, "-", jammin.vol_down,
      {description = "volume--", group = "media"}),

   -- Screencap
   awful.key({ }, "Print", function() awful.spawn("scrot -e 'mv $f ~/pics/screenshots/ 2>/dev/null'") end,
      {description = "screenshot", group = "screen"}),

   -- Etc
   awful.key({ modkey, "Shift" }, "Escape", util.conf_debug,
      {description = "get that data", group = "awesome"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   keys.globalkeys = awful.util.table.join(
      keys.globalkeys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}),
      -- Toggle tag display.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end,
         {description = "toggle tag #" .. i, group = "tag"}),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         {description = "move focused client to tag #"..i, group = "tag"}),
      -- Toggle tag on focused client.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:toggle_tag(tag)
               end
            end
         end,
         {description = "toggle focused client on tag #" .. i, group = "tag"})
   )
end

-- Add variable config
keys.globalkeys = awful.util.table.join(keys.globalkeys, var.globalkeys)
-- }}}

-- {{{ Global mouse bindings
keys.globalbuttons = awful.util.table.join(
   awful.button({ }, 3, function () menu.main:toggle() end),
   awful.button({ }, 8, awful.tag.viewnext),
   awful.button({ }, 9, awful.tag.viewprev)
)

-- Add variable config
keys.globalbuttons = awful.util.table.join(keys.globalbuttons, var.globalbuttons)
-- }}}

-- {{{ Client key bindings
keys.clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end,
      {description = "toggle fullscreen", group = "client"}),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
      {description = "close", group = "client"}),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ modkey, "Shift"   }, "Return",
      function (c)
         util.get_client_cwd(c, function(cwd) awful.spawn(var.terminal..' -cd "'..cwd..'"') end)
         -- if cwd then
         --    awful.spawn(var.terminal .. ' -cd "' .. cwd .. '"')
         -- end
      end,
      {description = "spawn terminal at current path", group = "client"}),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ modkey, "Shift"   }, "`",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
   awful.key({ modkey, "Shift"   }, "\\",      tags.to_transient_tag,
      {description = "move to transient tag", group = "client"}),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
      {description = "toggle keep on top", group = "client"}),
   awful.key({ modkey, "Shift"   }, "o",
      function (c)
         if c.opacity == 1.0 then
            c.opacity = 0.5
         else
            c.opacity = 1.0
         end
      end,
      {description = "toggle transparency", group = "client"}),
   awful.key({ modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end ,
      {description = "minimize", group = "client"}),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized_horizontal = false
         c.maximized_vertical = false
         c.maximized = not c.maximized
         c:raise()
      end ,
      {description = "maximize", group = "client"}),
   awful.key({ modkey, "Control" }, "m",
      function (c)
         c.maximized_vertical = not c.maximized_vertical
         c:raise()
      end ,
      {description = "maximize vertically", group = "client"}),
   awful.key({ modkey, "Shift"   }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c:raise()
      end ,
      {description = "maximize horizontally", group = "client"})

)

keys.clientkeys = awful.util.table.join(keys.clientkeys, var.clientkeys)

keys.clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize),
   awful.button({ modkey }, 9,
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
   end),
   awful.button({ modkey }, 8, function(c) c:kill() end)
)

keys.clientbuttons = awful.util.table.join(keys.clientbuttons, var.clientbuttons)
-- }}}

-- {{{ Widget key and mouse bindings
keys.taglist_buttons = awful.util.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

keys.taglist_buttons = awful.util.table.join(keys.taglist_buttons, var.taglist_buttons)

keys.tasklist_buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, menu.client),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
end))

keys.tasklist_buttons = awful.util.table.join(keys.tasklist_buttons, var.tasklist_buttons)

keys.layoutbox_buttons = awful.util.table.join(
   awful.button({ }, 1, function () awful.layout.inc( 1) end),
   awful.button({ }, 3, function () awful.layout.inc(-1) end),
   awful.button({ }, 4, function () awful.layout.inc( 1) end),
   awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

function keys.titlebar_buttons(c)
   awful.util.table.join(
      awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
      end),
      awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
      end)
   )
end
-- }}}

return keys
