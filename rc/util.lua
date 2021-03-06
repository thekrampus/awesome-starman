-- Utilities (called from rc.lua)
local naughty = require("naughty")
local wibox   = require("wibox")
local common  = require("awful.widget.common")
local spawn   = require("awful.spawn")
local dpi     = require("beautiful").xresources.apply_dpi
local nifty   = require("nifty")

local util = {}

-- {{{ Helper functions
function util.conf_debug()
   naughty.notify{title="𝒂𝒘𝒆𝒔𝒐𝒎𝒆", text="using " .. collectgarbage('count') .. " kb", font="Noto Sans 10"}
   nifty.util.log("Called util.conf_debug")
end

-- Call the provided callback with the current working directory of a given client if it has a shell
function util.get_client_cwd(c, callback)
   local cb = function(out, _, _, code)
      if code ~= 0 then
         nifty.util.log("Error getting client cwd (probably not a shell)")
      elseif string.len(out) > 0 then
         callback(string.gsub(out, '[\r\n]+$', ''))
      end
   end
   spawn.easy_async_with_shell("readlink /proc/(pgrep -P "..c.pid..")/cwd", cb)
end

function util.icon_list_update(w, buttons, label, data, objects)
   w:reset()
   for _, tag in ipairs(objects) do

      local cache = data[tag]
      local tagicon, taglabel, tagbg
      if cache then
         tagicon = cache.tagicon
         taglabel = cache.taglabel
         tagbg = cache.tagbg
      else
         tagicon = wibox.widget.imagebox()
         taglabel = wibox.widget.textbox()

         tagbg = wibox.container {
            {
               {
                  tagicon,
                  taglabel,
                  layout = wibox.layout.fixed.horizontal
               },
               left   = dpi(13),
               right  = dpi(13),
               widget = wibox.container.margin
            },
            widget = wibox.container.background
         }
         tagbg:buttons(common.create_buttons(buttons, tag))

         data[tag] = {
            tagicon = tagicon,
            taglabel = taglabel,
            tagbg = tagbg
         }
      end

      local text, bg, _, icon, args = label(tag)
      if icon then
         tagicon:set_image(icon)
      else
         if text == nil or text == "" then
            text = "tag"
         end
         taglabel:set_markup("<i>" .. text .. "</i>")
      end

      tagbg:set_bg(bg)
      tagbg.shape = args.shape
      tagbg.shape_border_width = args.shape_border_width
      tagbg.shape_border_color = args.shape_border_color

      w:add(tagbg)
   end
end

--- Replacement for wibox.layout.fixed:fit which respects negative spacing
-- @param context The context in which we are fit.
-- @param orig_width The available width.
-- @param orig_height The available height.
function util.fixed_fit(self, context, orig_width, orig_height)
   local width, height = orig_width, orig_height
   local used_in_dir, used_max = 0, 0

   local spacing = self._private.spacing

   for _, v in pairs(self._private.widgets) do
      local w, h = wibox.widget.base.fit_widget(self, context, v, width, height)
      local in_dir, max
      if self._private.dir == "y" then
         max, in_dir = w, h
         height = height - in_dir - spacing
      else
         in_dir, max = w, h
         width = width - in_dir - spacing
      end
      if max > used_max then
         used_max = max
      end

      used_in_dir = used_in_dir + in_dir + spacing

      if width <= 0 or height <= 0 then
         if self._private.dir == "y" then
            used_in_dir = orig_height
         else
            used_in_dir = orig_width
         end
         break
      end
   end

   if self._private.dir == "y" then
      return used_max, used_in_dir - spacing
   end
   return used_in_dir - spacing, used_max
end
-- }}}

return util
