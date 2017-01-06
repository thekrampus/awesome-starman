-- Tag configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local common = require("awful.widget.common")

local awesify = require("extensions.awesify")
local styleclock = require("extensions.styleclock")
local cpu_meter = require("extensions.cpu_meter")
local mem_meter = require("extensions.mem_meter")

-- Replacement for awful.widget.common.list_update for the taglist widget. Removes default tag width minimum.
local function minwidth_list_update(w, buttons, label, data, objects)
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

-- Create a textclock widget
local mytextclock = styleclock()

-- Create cpu_meter and mem_meter widgets
local mycpumeter = cpu_meter("Physical id 0", {0,1,2,3}, 2)
local mymemmeter = mem_meter(10, 5)

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag),
   awful.button({ }, 9, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 8, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
local mytasklist = {}
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
      right_layout:add(mycpumeter)
      right_layout:add(mymemmeter)
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

globalkeys = awful.util.table.join(globalkeys,
                                   -- Prompt
                                   awful.key({ modkey },            "space",     function () mypromptbox[mouse.screen]:run() end),
                                   awful.key({ modkey }, "x",
                                      function ()
                                         awful.prompt.run({ prompt = "Run Lua code: " },
                                            mypromptbox[mouse.screen].widget,
                                            awful.util.eval, nil,
                                            awful.util.getdir("cache") .. "/history_eval")
                                   end),

                                   -- Spotify controls
                                   awful.key({ modkey }, "Home", awesify.playpause),
                                   awful.key({ modkey }, "Prior", awesify.next),
                                   awful.key({ modkey }, "Insert", awesify.previous)
)

return mywibox
