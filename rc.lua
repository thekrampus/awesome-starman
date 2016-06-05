-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local common = require("awful.widget.common")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Custom extensions
local awesify = require("extensions.awesify")
local styleclock = require("extensions.styleclock")
local x_macros = require("extensions.x_macros")

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

-- {{{ Helper functions

function conf_debug()
   naughty.notify{title="HEY!", text="LISTEN!"}
end

-- Run a command and notify with output. Useful for debugging.
function run_and_notify(options)
   if type(options.cmd) ~= "string" then
      naughty.notify({text = "<span color\"red\">bad run_and_notify in rc.lua</span>"})
   else
      outstr = awful.util.pread(options.cmd .. " 2>&1")
      if options.notify then
         naughty.notify({title = options.cmd, text = outstr})
      end
   end
end

-- Recursively concat a table into a single formatted string.
function table_cat(t, depth)
   if depth == nil then
      depth = 0
   end
   indent = string.rep(" ", depth)
   if depth > 4 then
      return indent .. "[...]\n"
   end
   tcat = ""
   for k,v in pairs(t) do
      tcat = tcat .. indent .. tostring(k) .. " : "
      if type(v) == "table" then
         tcat = tcat .. "{\n" .. table_cat(v, depth+1) .. indent .. "}\n"
      else
         tcat = tcat .. tostring(v) .. "\n"
      end
   end
   return tcat
end

-- Replacement for awful.widget.common.list_update for the taglist widget. Removes default tag width minimum.
function minwidth_list_update(w, buttons, label, data, objects)
   -- update the widgets, creating them if needed
   w:reset()
   for i, o in ipairs(objects) do
      local cache = data[o]
      local ib, tb, bgb, m, l
      if cache then
         ib = cache.ib
         tb = cache.tb
         bgb = cache.bgb
         m   = cache.m
      else
         ib = wibox.widget.imagebox()
         tb = wibox.widget.textbox()
         bgb = wibox.widget.background()
         m = wibox.layout.margin(tb, 4, 4)
         l = wibox.layout.fixed.horizontal()

         -- All of this is added in a fixed widget
         l:fill_space(true)
         l:add(m) -- add margin on left and right
         l:add(ib)
         l:add(m)

         -- And all of this gets a background
         bgb:set_widget(l)

         bgb:buttons(common.create_buttons(buttons, o))

         data[o] = {
            ib = ib,
            tb = tb,
            bgb = bgb,
            m   = m
         }
      end

      local text, bg, bg_image, icon = label(o)
      -- The text might be invalid, so use pcall
      if not pcall(tb.set_markup, tb, text) then
         tb:set_markup("<i>&lt;Invalid text&gt;</i>")
      end
      bgb:set_bg(bg)
      if type(bg_image) == "function" then
         bg_image = bg_image(tb,o,m,objects,i)
      end
      bgb:set_bgimage(bg_image)
      ib:set_image(icon)
      w:add(bgb)
   end
end

function irc_loadout()
   awful.util.spawn(terminal .. " -e irssi --config=/home/rob/.irssi/sudonet.conf")
   awful.util.spawn(terminal .. " -e irssi --config=/home/rob/.irssi/nmtcs.conf")
end

function spawn_loadout()
   irc_loadout()
   awful.util.spawn("spotify")
   awful.util.spawn("steam")
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/starman/theme.lua")

-- Custom layout patching
awful.layout.suit.tile = require("patch.tile")
awful.layout.suit.spiral = require("patch.spiral")
awful.layout.suit.max = require("patch.max")
awful.menu = require("patch.menu")

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

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
   {
      awful.layout.suit.floating,
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      --awful.layout.suit.tile.bottom,
      awful.layout.suit.tile.top,
      --awful.layout.suit.fair,
      --awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral,
      --awful.layout.suit.spiral.dwindle,
      awful.layout.suit.max,
      --awful.layout.suit.max.fullscreen,
      --awful.layout.suit.magnifier
   }
-- }}}

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

-- {{{ Tags
-- Define a tag table which hold all screen tags.
icons = beautiful.icondir
tags = {
   names = { "", "", "", "", "", "" },
   layout = { layouts[2], layouts[2], layouts[2], layouts[6], layouts[6], layouts[5]},
   icons = { icons .. "prime.png", icons .. "irc.png", icons .. "net.png", icons .. "jams.png", icons .. "games.png", icons .. "epsilon.png"}
}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
   for i, t in ipairs(tags[s]) do
      awful.tag.seticon(tags.icons[i], t)
   end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "check config", function() run_and_notify({cmd="awesome -k", notify=true}) end},
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

toolmenu = {
   { "dropbox status", "/home/rob/Files/dropbox_notify.sh"},
   { "htop", terminal .. " -e htop" },
   { "dmesg", terminal .. " -e dmesg -wH" }
}

macromenu = x_macros.build_menu()

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                             { "x_macros", macromenu },
                             { "tools", toolmenu },
                             { "spawn irc", irc_loadout },
                             { "spawn loadout", spawn_loadout },
                             { "open terminal", terminal } }
                       })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock()
mytextclock = styleclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 9, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 8, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, function ()
         if instance then
            instance:hide()
            instance = nil
         else
            instance = awful.menu.clients({ width=250 })
         end
   end),
   awful.button({ }, 9, function ()
         awful.client.focus.byidx(1)
         if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 8, function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
                             awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             awful.button({ }, 9, function () awful.layout.inc(layouts, 1) end),
                             awful.button({ }, 8, function () awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   -- mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons, nil, minwidth_list_update)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   -- if s == 1 then right_layout:add(wibox.widget.systray()) end
   if s == 1 then
      right_layout:add(awesify.create_playbox())
      right_layout:add(awesify.create_musicbox())
   end
   right_layout:add(mytextclock)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)

   local b = beautiful.border_padding or 0
   awful.screen.padding(screen[s], {top=b, left=b, right=b, bottom=b})
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
                awful.button({ }, 3, function () mymainmenu:toggle() end),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey, "Shift"   }, "[",   awful.tag.viewprev),
   awful.key({ modkey, "Shift"   }, "]",  awful.tag.viewnext),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

   awful.key({ modkey,           }, "Right",
      function ()
         awful.client.focus.byidx( 1)
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "Left",
      function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Shift"   }, "/", awful.client.urgent.jumpto),
   awful.key({ modkey, "Control" }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
   end),

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
   awful.key({ modkey, "Shift"   }, "q", awesome.quit),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, "Tab", function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "Tab", function () awful.layout.inc(layouts, -1) end),

   awful.key({ modkey, "Control" }, "n", awful.client.restore),

   -- Prompt
   awful.key({ modkey },            "space",     function () mypromptbox[mouse.screen]:run() end),
   
   awful.key({ modkey }, "x",
      function ()
         awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen].widget,
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
   end),
   -- Menubar
   awful.key({ modkey }, "p", function() menubar.show() end),

   -- Print Screen
   awful.key({ }, "Print", function() awful.util.spawn("scrot -e 'mv $f ~/pics/screenshots/ 2>/dev/null'") end),

   -- Macro Hotkey
   awful.key({ modkey, "Shift" }, "e", x_macros.hot_macro),
   
   -- Spotify controls
   awful.key({ modkey }, "Home", awesify.playpause),
   awful.key({ modkey }, "Prior", awesify.next),
   awful.key({ modkey }, "Insert", awesify.previous),

   awful.key({ modkey, "Shift"   }, "space",  conf_debug)
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey, "Shift"   }, "`",      awful.client.movetoscreen                        ),
   awful.key({ modkey,           }, "`",      function (c) awful.screen.focus_relative(1)   end),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
   end),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical   = not c.maximized_vertical
   end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({ modkey }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            if tags[screen][i] then
                                               awful.tag.viewonly(tags[screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Control" }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            if tags[screen][i] then
                                               awful.tag.viewtoggle(tags[screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus and tags[client.focus.screen][i] then
                                               awful.client.movetotag(tags[client.focus.screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus and tags[client.focus.screen][i] then
                                               awful.client.toggletag(tags[client.focus.screen][i])
                                            end
   end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 9,
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
   end),
   awful.button({ modkey }, 8, function(c) c:kill() end),

   awful.button({ modkey }, 3, awful.mouse.client.resize)),

-- Set keys
root.keys(globalkeys)
-- }}}

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
     properties = { floating = true } },
   { rule = { name = "irssi" },
     properties = { tag = tags[1][2] } },
   { rule = { class = "Spotify" },
     properties = { tag = tags[2][4] } },
   { rule = { class = "Steam" },
     properties = { tag = tags[2][5] } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
                         -- Enable sloppy focus
                         c:connect_signal("mouse::enter", function(c)
                                             if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                             and awful.client.focus.filter(c) then
                                                client.focus = c
                                             end
                         end)

                         if not startup then
                            -- Set the windows at the slave,
                            -- i.e. put it at the end of others instead of setting it master.
                            -- awful.client.setslave(c)

                            -- Put windows in a smart way, only if they does not set an initial position.
                            if not c.size_hints.user_position and not c.size_hints.program_position then
                               awful.placement.no_overlap(c)
                               awful.placement.no_offscreen(c)
                            end
                         end

                         local titlebars_enabled = false
                         if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
                            -- Widgets that are aligned to the left
                            local left_layout = wibox.layout.fixed.horizontal()
                            left_layout:add(awful.titlebar.widget.iconwidget(c))

                            -- Widgets that are aligned to the right
                            local right_layout = wibox.layout.fixed.horizontal()
                            right_layout:add(awful.titlebar.widget.floatingbutton(c))
                            right_layout:add(awful.titlebar.widget.maximizedbutton(c))
                            right_layout:add(awful.titlebar.widget.stickybutton(c))
                            right_layout:add(awful.titlebar.widget.ontopbutton(c))
                            right_layout:add(awful.titlebar.widget.closebutton(c))

                            -- The title goes in the middle
                            local title = awful.titlebar.widget.titlewidget(c)
                            title:buttons(awful.util.table.join(
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
                            ))

                            -- Now bring it all together
                            local layout = wibox.layout.align.horizontal()
                            layout:set_left(left_layout)
                            layout:set_right(right_layout)
                            layout:set_middle(title)

                            awful.titlebar(c):set_widget(layout)
                         end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Naughty
-- Hook awesify into Spotify; suppress default notifications
naughty.config.presets.spotify = {callback = awesify.update_music}
table.insert(naughty.config.mapping, {{appname = "Spotify"}, naughty.config.presets.spotify})
-- }}}
