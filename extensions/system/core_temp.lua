--- CPU Core temperature sysfs monitor
local sysfs = require('sysfs_base')
local nifty = require('nifty')

local core_temp = sysfs:_subclass{
   _repr = 'Core Temperature Monitor'
}

local DEFAULT_ARGS = {
   sysfs_path = '/sys/class/hwmon/hwmon1/', -- default on my system
   poll_rate = 5, -- poll every 5 seconds
   units = 'celsius' -- one of (celsius, kelvin, fahrenheit)
}

local function celsius_filter(raw)
   return tonumber(raw) / 1000.0
end

local function kelvin_filter(raw)
   return celsius_filter(raw) + 273.15
end

local function fahrenheit_filter(raw)
   return (celsius_filter(raw) * 9/5) + 32
end

local filter_map = {
   celsius = celsius_filter,
   centigrade = celsius_filter,
   c = celsius_filter,
   metric = celsius_filter,
   kelvin = kelvin_filter,
   k = kelvin_filter,
   fahrenheit = fahrenheit_filter,
   f = fahrenheit_filter,
   imperial = fahrenheit_filter,
}

function core_temp:get_by_label(label, property)
   property = property or "input"
   for k, v in self:matches('^temp.*_label$') do
      if v:match(label) then
         local label_name = k:match('^(.*)label$') .. property
         return self:get(label_name)
      end
   end
end

-- Core temperatures are also indexible by label
function core_temp:get(name)
   local ret = sysfs.get(self, name)
   if ret then
      return ret
   else
      return self:get_by_label(name, "input")
   end
end

-- Construct a new core temperature monitor
function core_temp:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   sysfs._init(self, args)

   local filter_fn = filter_map[args.units:lower()]

   self:_add_endpoint('name', 0)
   self:_add_endpoint('temp*_label', 0)
   self:_add_endpoint('temp*_{max,crit,crit_alarm}', 0, filter_fn)
   self:_add_endpoint('temp*_input', self.poll_rate, filter_fn)

   return self
end

return core_temp
