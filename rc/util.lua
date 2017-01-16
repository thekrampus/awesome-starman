-- Utilities (called from rc.lua)
local naughty = require("naughty")
local wibox = require("wibox")
local common = require("awful.widget.common")
local dpi = require("beautiful").xresources.apply_dpi

local nifty = require("nifty")
local util = {}

local log_date_fmt = "%Y%m%d.%X"
local log_stat_fmt = "%8.3fs %8.1fkb"
local log_fmt = "%s %s: %s%s<%s>"
local log_width = 100

-- {{{ Helper functions
function util.conf_debug()
   naughty.notify{title="𝒂𝒘𝒆𝒔𝒐𝒎𝒆", text="using " .. collectgarbage('count') .. " kb", font="Noto Sans 10"}
   nifty.util.log("Called util.conf_debug")
end

-- Run a command synchronously and return its output, or nil if the command failed
-- This is synchronous and will block until the program call returns
-- For the same thing asynchronously, see awful.spawn.easy_async
function util.pread(command)
   local proc = io.popen(command)
   local raw = proc:read("*a")
   proc:close()
   return raw
end

-- Read the contents of a file synchronously and return as a string, or nil if reading failed
-- This is synchronous and will block until the program call returns
function util.read(filename)
   local file = io.open(filename, 'r')
   if file then
      local raw = file:read("*a")
      file:close()
      return raw
   else
      return nil
   end
end

-- Recursively concat a table into a single formatted string.
function util.table_cat(t, depth)
   if depth == nil then
      depth = 0
   end
   local indent = string.rep(" ", depth)
   if depth > 4 then
      return indent .. "[...]\n"
   end
   local tcat = ""
   for k,v in pairs(t) do
      tcat = tcat .. indent .. tostring(k) .. " : "
      if type(v) == "table" then
         tcat = tcat .. "{\n" .. util.table_cat(v, depth+1) .. indent .. "}\n"
      else
         tcat = tcat .. tostring(v) .. "\n"
      end
   end
   return tcat
end

-- Get the current working directory of a given client if it has a shell (nil otherwise)
function util.get_client_cwd(c)
   -- Get PID of first child of the client
   local pid = string.gsub(util.pread("pgrep -P " .. math.floor(c.pid)), '[\r\n]+$', '')
   -- Get CWD from system fs
   local cwd = string.gsub(util.pread("readlink /proc/" .. pid .. "/cwd"), '[\r\n]+$', '')
   if string.len(cwd) > 0 then
      return cwd
   else
      return nil
   end
end

-- Sanitize a string for display in a textbox widget
function util.sanitize(raw_string)
   raw_string = string.gsub(raw_string, "&", "&amp;")
   raw_string = string.gsub(raw_string, "<", "&lt;")
   raw_string = string.gsub(raw_string, ">", "&gt;")
   raw_string = string.gsub(raw_string, "'", "&apos;")
   raw_string = string.gsub(raw_string, "\"", "&quot;")
   return raw_string
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
