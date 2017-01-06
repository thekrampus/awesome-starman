-- Utilities (called from rc.lua)
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local common = require("awful.widget.common")
local dpi = require("beautiful").xresources.apply_dpi

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
      local ib, tb, bgb, tbm, ibm, l
      if cache then
         ib = cache.ib
         tb = cache.tb
         bgb = cache.bgb
         tbm = cache.tbm
         ibm = cache.ibm
      else
         ib = wibox.widget.imagebox()
         tb = wibox.widget.textbox()
         bgb = wibox.container.background()
         tbm = wibox.container.margin(tb, dpi(4), dpi(4))
         ibm = wibox.container.margin(ib, dpi(12), dpi(12))
         l = wibox.layout.fixed.horizontal()

         -- All of this is added in a fixed widget
         l:fill_space(true)
         l:add(ibm)
         -- l:add(tbm)

         -- And all of this gets a background
         bgb:set_widget(l)

         bgb:buttons(common.create_buttons(buttons, o))

         data[o] = {
            ib  = ib,
            tb  = tb,
            bgb = bgb,
            tbm = tbm,
            ibm = ibm,
         }
      end

      local text, bg, bg_image, icon, args = label(o, tb)
      args = args or {}

      -- The text might be invalid, so use pcall.
      if text == nil or text == "" then
         tbm:set_margins(0)
      else
         if not tb:set_markup_silently(text) then
            tb:set_markup("<i>&lt;Invalid text&gt;</i>")
         end
      end
      bgb:set_bg(bg)
      if type(bg_image) == "function" then
         -- TODO: Why does this pass nil as an argument?
         bg_image = bg_image(tb,o,nil,objects,i)
      end
      bgb:set_bgimage(bg_image)
      if icon then
         ib:set_image(icon)
      else
         ibm:set_margins(0)
      end

      bgb.shape              = args.shape
      bgb.shape_border_width = args.shape_border_width
      bgb.shape_border_color = args.shape_border_color

      w:add(bgb)
   end
   -- -- update the widgets, creating them if needed
   -- w:reset()
   -- for i, o in ipairs(objects) do
   --    local cache = data[o]
   --    local ib, tb, bgb, m, l
   --    if cache then
   --       ib = cache.ib
   --       tb = cache.tb
   --       bgb = cache.bgb
   --       m   = cache.m
   --    else
   --       ib = wibox.widget.imagebox()
   --       tb = wibox.widget.textbox()
   --       bgb = wibox.widget.background()
   --       m = wibox.layout.margin(tb, 4, 4)
   --       l = wibox.layout.fixed.horizontal()

   --       -- All of this is added in a fixed widget
   --       l:fill_space(true)
   --       l:add(m) -- add margin on left and right
   --       l:add(ib)
   --       l:add(m)

   --       -- And all of this gets a background
   --       bgb:set_widget(l)

   --       bgb:buttons(common.create_buttons(buttons, o))

   --       data[o] = {
   --          ib = ib,
   --          tb = tb,
   --          bgb = bgb,
   --          m   = m
   --       }
   --    end

   --    local text, bg, bg_image, icon = label(o)
   --    -- The text might be invalid, so use pcall
   --    if not pcall(tb.set_markup, tb, text) then
   --       tb:set_markup("<i>&lt;Invalid text&gt;</i>")
   --    end
   --    bgb:set_bg(bg)
   --    if type(bg_image) == "function" then
   --       bg_image = bg_image(tb,o,m,objects,i)
   --    end
   --    bgb:set_bgimage(bg_image)
   --    ib:set_image(icon)
   --    w:add(bgb)
   -- end
end
-- }}}
