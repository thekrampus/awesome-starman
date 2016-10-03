-- A widget to poll and display useful cpu temperature & usage info

local setmetatable = setmetatable
local awful = require("awful")
local textbox = require("wibox.widget.textbox")
local capi = { timer = timer }
local cpu_meter = { mt = {} }

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

local last_stat = nil

function cpu_meter.parseTemp(output, sensor)
   local readings = string.match(output, sensor .. ":\n(.-)\n[^%s]")
   local input = tonumber(string.match(readings, "[%w]+_input:%s+([%d%.]+)"))
   local max = tonumber(string.match(readings, "[%w]+_max:%s+([%d%.]+)"))
   local crit = tonumber(string.match(readings, "[%w]+_crit:%s+([%d%.]+)"))
   local crit_alarm = tonumber(string.match(readings, "[%w]+_crit_alarm:%s+([%d%.]+)"))
   return input, temp_elevated, max, crit
end

-- function cpu_meter.parseTemp(output, sensor)
--    local readings = string.match(output, sensor .. ":\n(.-)\n[^%s]")
--    local input = tonumber(string.match(readings, "[%w]+_input:%s+([%d%.]+)"))
--    return input, temp_elevated, temp_max, temp_crit
-- end


function cpu_meter.parseUsage(output)
   local stat = {}
   local usage = {}

   
   for ln in string.gmatch(output, "[^\n]+") do
      local core, idle, total = string.match(ln, "(%S+)%s+(%S+)%s+(%S+)")
      stat[core] = {idle=idle, total=total}
   end

   if last_stat == nil then
      for k,v in pairs(stat) do
         usage[k] = 0
      end
   else
      for k,v in pairs(stat) do
         local d_idle = v['idle'] - last_stat[k]['idle']
         local d_total = v['total'] - last_stat[k]['total']
         if d_total == 0 then
            usage[k] = 0
         else
            usage[k] = 1.0 - (d_idle / d_total)
         end
      end
   end

   last_stat = stat
   
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
   local timer = capi.timer { timeout = timeout }
   
   function poll()
      local statstr = awful.util.pread("awk '/^cpu[0-9]/{ print $1, $5, ($2 + $3 + $4 + $5 + $6 + $7 + $8);}' /proc/stat 2>&1")
      local usage = cpu_meter.parseUsage(statstr)
      
      local tempstr = awful.util.pread("sensors -u 2>&1")
      local i, e, m, c = cpu_meter.parseTemp(tempstr, readout_sensor)
      local markup = '[' .. cpu_meter.make_readout(i, e, m, c) .. '|'

      for i,n in ipairs(cores) do
         markup = markup .. cpu_meter.make_glyph(n, usage, tempstr)
      end

      markup = markup .. ']'
      
      w:set_markup(markup)
   end
   
   timer:connect_signal("timeout", poll)
   timer:start()
   timer:emit_signal("timeout")
   return w
end

function cpu_meter.mt:__call(...)
   return cpu_meter.new(...)
end

return setmetatable(cpu_meter, cpu_meter.mt)
