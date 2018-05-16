-- A widget to show disk usage polled at regular intervals
local setmetatable = setmetatable

local awful   = require("awful")
local tooltip = require("awful.tooltip")
local wibox   = require("wibox")
local timer   = require("gears.timer")

local disk_meter = { mt = {} }

local def_args = {
   timeout = 60,
   base_widget = wibox.widget {
      layout = wibox.layout.fixed.horizontal,
      spacing = 1
   }
}

local meter_fg = "white"
local meter_bg = "gray"

-- local glyphs = {'⡀⠀', '⣄⠀', '⣦⡀', '⣷⣄', '⣿⣦', '⣿⣷', '⣿⣿'}
-- local glyphs = {'⣀', '⣤', '⣶', '⣿'}
-- local glyphs = {'⡀', '⣄', '⣦', '⣷', '⣿'}
local glyphs = {'⠀', '⡀', '⣀', '⣄', '⣤', '⣦', '⣶', '⣷', '⣿'}
-- local glyphs = {'⠀', '⡀', '⡄', '⡆', '⡇'}

--- wrapping in bash for multi-shell compatability (whatever! cool kids use fish!)
local poll_cmd    = "bash -c 'paste <(df --no-sync --local -x tmpfs -x devtmpfs | awk \\'{print $1, $2, $3}\\') <(df --no-sync --human-readable --local -x tmpfs -x devtmpfs | awk \\'{print $4, $6}\\')'"
local display_cmd = "df --no-sync --local --human-readable -x tmpfs -x devtmpfs"

local meter_fmt     = string.format("<span color=\"%s\">%s</span>", meter_fg, "%s")
local meter_tip_fmt = "<span color=\"white\">%s</span> :: <span color=\"green\">%s</span> free"
local bg_span       = string.format("<span color=\"%s\">%s</span>", meter_bg, glyphs[#glyphs])

-- Parse a meter's usage from output and update
local function parse_output(meter, output)
   if not meter._disk then
      return  -- ceci n'est pas un metre...
   end

   local total, used, free, mount_pt = string.match(output, meter._disk.."%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S*)")

   local pct_used = tonumber(used) / tonumber(total)
   local glyph = glyphs[math.min(#glyphs, math.floor(pct_used * #glyphs + 1))]

   meter._fg:set_markup(meter_fmt:format(glyph))
   meter._ttip:set_markup(meter_tip_fmt:format(mount_pt or meter._disk, free))
end

--- Build a new disk meter widget.
-- @param disks       list of names of disks to display
-- @param timeout     period of polling, in seconds
-- @param base_widget container widget supporting `add` method and `children` property
-- @return A disk meter widget
function disk_meter.new(args)
   local timeout = args.timeout or def_args.timeout

   local base = args.base_widget or def_args.base_widget
   for _, disk in ipairs(args.disks) do
      local fg = wibox.widget.textbox()
      local w = wibox.widget {
         wibox.widget.textbox(bg_span),
         fg,
         layout = wibox.layout.stack
      }
      w._fg = fg
      w._disk = disk
      w._ttip = tooltip({
            objects= {w},
            delay_show = 0.2
      })
      base:add(w)
   end

   local function callback(out, err, _, status)
      if status ~= 0 then
         print("\nNonzero exit code from disk_meter poll: " .. status)
         print(err)
         return
      end

      for _, child in ipairs(base.children) do
         parse_output(child, out)
      end
   end

   -- run once to initialize widget
   awful.spawn.easy_async_with_shell(poll_cmd, callback)

   -- start polling
   timer.start_new(timeout, function() awful.spawn.easy_async_with_shell(poll_cmd, callback) end)
   local w = wibox.widget {
      wibox.widget.textbox("["),
      base,
      wibox.widget.textbox("]"),
      layout = wibox.layout.fixed.horizontal
   }

   return w
end

function disk_meter.mt:__call(...)
   return disk_meter.new(...)
end

return setmetatable(disk_meter, disk_meter.mt)
