-- A widget to poll and display useful cpu temperature & usage info
local awful = require("awful")
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local cpu_meter = {}
cpu_meter.__index = cpu_meter

local usage_call = "awk '/^cpu[0-9]/{ print $1, $5, ($2 + $3 + $4 + $5 + $6 + $7 + $8);}' /proc/stat"
local sensor_call = "sensors -u"

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
local stats = {}
stats.__index = stats

function stats.new()
   local self = setmetatable({}, stats)
   self.buffer = {}
   self.capacity = 2
   self.tail = 1

   return self
end

function stats:getn()
   return #self.buffer
end

function stats:push(item)
   self.buffer[self.tail] = item
   self.tail = (self.tail % self.capacity) + 1
end

function stats:peek()
   if self:getn() < self.capacity then
      return self.buffer[1]
   else
      return self.buffer[self.tail]
   end
end

local function get_usage(prev, new)
   local usage = {}

   for k,v in pairs(new) do
      local d_idle = v['idle'] - prev[k]['idle']
      local d_total = v['total'] - prev[k]['total']
      if d_total == 0 then
         usage[k] = 0
      else
         usage[k] = 1.0 - (d_idle / d_total)
      end
   end

   return usage
end

local function parse_temp(output, sensor)
   local readings = string.match(output, sensor .. ":\n(.-)\n[^%s]")
   local input = tonumber(string.match(readings, "[%w]+_input:%s+([%d%.]+)"))
   return input, temp_elevated, temp_max, temp_crit
end

local function color_by_temp(input, elevated, max, crit)
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

-- Make a numeric temperature readout. Input is assumed in degrees Celsius.
local function make_readout(input, elevated, max, crit)
   local color = color_by_temp(input, elevated, max, crit)
   return '<span color="' .. color .. '">' .. math.floor(input) .. '°C</span>'
end

-- Make a usage glyph for a CPU core
local function make_glyph(n, usage, tempstr)
   local core_usage = usage['cpu' .. n]
   local glyph = usage_glyphs[math.min(#usage_glyphs,
                                       math.floor(core_usage * #usage_glyphs + 1))]
   local i, e, m, c = parse_temp(tempstr, 'Core ' .. n)
   local color = color_by_temp(i, e, m, c)

   return '<span color="' .. color .. '">' .. glyph .. '</span>'
end

-- Set widget markup using cached usage statistics and polled sensor output
function cpu_meter:make_markup(sensor_out)
   local i, e, m, c = parse_temp(sensor_out, self.sensor)
   local markup = '[' .. make_readout(i, e, m, c) .. '|'

   for _, n in ipairs(self.cores) do
      markup = markup .. make_glyph(n, self.usage, sensor_out)
   end

   markup = markup .. ']'
   self.wibox:set_markup(markup)
end

-- Sensors command callback. Parse command output and set widget markup
function cpu_meter:parse_sensors(stdout, stderr, exitreason, exitcode)
   if exitcode ~= 0 then
      print("\nNonzero exit code from cpu_meter sensors call: " .. exitcode)
      print(stderr)
      return
   end

   self:make_markup(stdout)
end

-- Usage command callback. Parse command output, add to stats,
-- and make asynchronous call to temperature sensors
function cpu_meter:parse_usage(stdout, stderr, exitreason, exitcode)
   if exitcode ~= 0 then
      print("\nNonzero exit code from cpu_meter usage call: " .. exitcode)
      print(stderr)
      return
   end

   local stat = {}
   for ln in string.gmatch(stdout, "[^\n]+") do
      local core, idle, total = string.match(ln, "(%S+)%s+(%S+)%s+(%S+)")
      stat[core] = {idle=idle, total=total}
   end

   self.stats:push(stat)
   self.usage = get_usage(self.stats:peek(), stat)

   awful.spawn.easy_async(sensor_call, function(...) self:parse_sensors(...) end)
end

function cpu_meter.new(readout_sensor, cores, timeout)
   local timeout = timeout or 1

   local self = setmetatable({}, cpu_meter)
   self.stats = stats.new()
   self.wibox = textbox()
   self.sensor = readout_sensor
   self.cores = cores
   self.usage = nil

   local function poll()
      awful.spawn.easy_async(usage_call, function(...) self:parse_usage(...) end)
      return true
   end

   poll()
   timer.start_new(timeout, poll)

   return self.wibox
end

setmetatable(cpu_meter, {
                __call = function(cls, ...)
                   return cls.new(...)
                end
})

return cpu_meter
