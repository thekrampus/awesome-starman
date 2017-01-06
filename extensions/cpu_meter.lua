-- A widget to poll and display useful cpu temperature & usage info
local setmetatable = setmetatable
local util = require("rc.util")
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local cpu_meter = { mt = {} }

local usage_call = "awk '/^cpu[0-9]/{ print $1, $5, ($2 + $3 + $4 + $5 + $6 + $7 + $8);}' /proc/stat 2>&1"
local sensor_call = "sensors -u 2>&1"

local color_normal = "gray"
local color_elevated = "white"
local color_high = "orange"
local color_crit = "red"

-- Temperature thresholds. These can be provided by sensors,
-- or alternately hardcoded since they're unlikely to change...
local temp_elevated = 65
local temp_max = 85
local temp_crit = 105

local usage_glyphs = {'⣀', '⣤', '⣶', '⣿'}

-- Buffer stats as a FIFO
local stats = { buffer={}, capacity = 2, tail = 1 }

function stats.getn()
   return #stats.buffer
end

function stats.push(item)
   stats.buffer[stats.tail] = item
   stats.tail = (stats.tail % stats.capacity) + 1
end

function stats.peek()
   if stats.getn() < stats.capacity then
      return stats.buffer[1]
   else
      return stats.buffer[stats.tail]
   end
end

-- function cpu_meter.parseTemp(output, sensor)
--    local readings = string.match(output, sensor .. ":\n(.-)\n[^%s]")
--    local input = tonumber(string.match(readings, "[%w]+_input:%s+([%d%.]+)"))
--    local max = tonumber(string.match(readings, "[%w]+_max:%s+([%d%.]+)"))
--    local crit = tonumber(string.match(readings, "[%w]+_crit:%s+([%d%.]+)"))
--    local crit_alarm = tonumber(string.match(readings, "[%w]+_crit_alarm:%s+([%d%.]+)"))
--    return input, temp_elevated, max, crit
-- end

function cpu_meter.parseTemp(output, sensor)
   local readings = string.match(output, sensor .. ":\n(.-)\n[^%s]")
   local input = tonumber(string.match(readings, "[%w]+_input:%s+([%d%.]+)"))
   return input, temp_elevated, temp_max, temp_crit
end


function cpu_meter.parseUsage(output)
   local stat = {}
   local usage = {}


   for ln in string.gmatch(output, "[^\n]+") do
      local core, idle, total = string.match(ln, "(%S+)%s+(%S+)%s+(%S+)")
      stat[core] = {idle=idle, total=total}
   end

   stats.push(stat)
   local last_stat = stats.peek()

   for k,v in pairs(stat) do
      local d_idle = v['idle'] - last_stat[k]['idle']
      local d_total = v['total'] - last_stat[k]['total']
      if d_total == 0 then
         usage[k] = 0
      else
         usage[k] = 1.0 - (d_idle / d_total)
      end
   end

   return usage
end

function cpu_meter.color_by_temp(input, elevated, max, crit)
   local c = color_crit
   if input < elevated then
      c = color_normal
   elseif input < max then
      c = color_elevated
   elseif input < crit then
      c = color_high
   end

   return c
end

function cpu_meter.make_readout(input, elevated, max, crit)
   local color = cpu_meter.color_by_temp(input, elevated, max, crit)
   return '<span color="' .. color .. '">' .. math.floor(input) .. '°C</span>'
end

function cpu_meter.make_glyph(n, usage, tempstr)
   local core_usage = usage['cpu' .. n]
   local glyph = usage_glyphs[math.min(#usage_glyphs,
                                       math.floor(core_usage * #usage_glyphs + 1))]
   local i, e, m, c = cpu_meter.parseTemp(tempstr, 'Core ' .. n)
   local color = cpu_meter.color_by_temp(i, e, m, c)

   return '<span color="' .. color .. '">' .. glyph .. '</span>'
end

function cpu_meter.new(readout_sensor, cores, timeout)
   local timeout = timeout or 1

   local w = textbox()

   local function poll()
      local statstr = util.pread(usage_call)
      local tempstr = util.pread(sensor_call)

      local usage = cpu_meter.parseUsage(statstr)
      local i, e, m, c = cpu_meter.parseTemp(tempstr, readout_sensor)
      local markup = '[' .. cpu_meter.make_readout(i, e, m, c) .. '|'

      for _,n in ipairs(cores) do
         markup = markup .. cpu_meter.make_glyph(n, usage, tempstr)
      end

      markup = markup .. ']'

      w:set_markup(markup)
      return true
   end

   poll()
   timer.start_new(timeout, poll)

   return w
end

function cpu_meter.mt:__call(...)
   return cpu_meter.new(...)
end

return setmetatable(cpu_meter, cpu_meter.mt)
