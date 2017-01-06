-- Client configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local client_ext = require("extensions.client_ext")

local titlebars_enabled = false

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

-- {{{ Global key mapping related to clients
globalkeys = awful.util.table.join(globalkeys,
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

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "Right", function() awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "Left", function() awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Shift"   }, "/", awful.client.urgent.jumpto),
   awful.key({ modkey, "Control" }, "Tab",
      function()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
   end),
   awful.key({ modkey, "Control" }, "n", awful.client.restore)
)
-- }}}

-- {{{ Client key & button mapping
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
   end),
   awful.key({ modkey, "Shift"   }, "f", client_ext.drag_float, client_ext.drop_float)
)

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

   awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}
