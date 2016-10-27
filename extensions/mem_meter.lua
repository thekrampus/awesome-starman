-- A widget to poll and display useful memory usage info

local setmetatable = setmetatable
local awful = require("awful")
local textbox = require("wibox.widget.textbox")
local capi = { timer = timer }
local mem_meter = { mt = {} }

local color_free = "gray"
local color_used = "white"
local color_high = "orange"
local color_swap = "red"

-- Width of usage meter, in glyphs, for total actual memory.
-- The swap meter extends beyond this, so the max possible width is
-- this plus the equivalent proportion of total swap
local total_width_default = 10

-- Memory usage greater than this percent will be rendered in color_high
local pct_high = 0.7

local timeout_default = 1

local usage_glyph = ':'

local readout_string = string.format('[<span color="%s">%s</span><span color="%s">%s</span><span color="%s">%s</span><span color="%s">%s</span>]',
                                     color_used, "%s",
                                     color_high, "%s",
                                     color_free, "%s",
                                     color_swap, "%s")

function mem_meter.parseUsage(output)
   local mem_line, swap_line = output:match("(Mem:.*)\n.*(Swap:.*)$")

   local _, mem_total, mem_used = mem_line:match(("(%S+)%s*"):rep(3))
   local _, swap_total, swap_used = swap_line:match(("(%S+)%s*"):rep(3))

   return mem_total, mem_used, swap_used
end

function mem_meter.make_readout(total, used, swap, total_width)
   local n_swap = math.floor(total_width * swap / total)
   local n_used = math.floor(total_width * used / total)
   local n_high = n_used - math.floor(total_width * pct_high)
   n_high = (n_high > 0 and n_high or 0)
   n_used = n_used - n_high
   local n_free = total_width - n_used - n_high

   print(string.format("%d, %d, %d, %d", n_used, n_high, n_free, n_swap))

   local readout = string.format(readout_string,
                                 (usage_glyph):rep(n_used),
                                 (usage_glyph):rep(n_high),
                                 (usage_glyph):rep(n_free),
                                 (usage_glyph):rep(n_swap))

   return readout
end

function mem_meter.new(total_width, timeout)
   local timeout = timeout or timeout_default
   local total_width = total_width or total_width_default

   local w = textbox()
   local timer = capi.timer { timeout = timeout }

   function poll()
      local memstr = awful.util.pread("free --kilo 2>&1")
      local total, used, swap = mem_meter.parseUsage(memstr)
      local markup = mem_meter.make_readout(total, used, swap, total_width)

      w:set_markup(markup)
   end

   timer:connect_signal("timeout", poll)
   timer:start()
   timer:emit_signal("timeout")
   return w
end

function mem_meter.mt:__call(...)
   return mem_meter.new(...)
end

return setmetatable(mem_meter, mem_meter.mt)
