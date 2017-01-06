-- Utilities (called from rc.lua)
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local common = require("awful.widget.common")

-- {{{ Helper functions
function conf_debug()
   naughty.notify{title="HEY!", text="LISTEN!"}
end

-- Run a command and notify with output. Useful for debugging.
function run_and_notify(options)
   if type(options.cmd) ~= "string" then
      naughty.notify({text = "<span color\"red\">bad run_and_notify in rc.lua</span>"})
   else
      outstr = awful.spawn.easy_async(options.cmd .. " 2>&1")
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
-- }}}
