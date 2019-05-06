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

local function sensor_filter(parse_table)
   local sensors = {}
   for k, v in pairs(parse_table) do
      local sensor, endpt = k:match("^(temp%d+)_(%S+)$")
      if not sensors[sensor] then
         sensors[sensor] = {}
      end
      sensors[sensor][endpt] = v
   end
   return sensors
end

local function label_filter_factory(self)
   return function(parse_table)
      parse_table = sensor_filter(parse_table)
      for k, v in pairs(parse_table) do
         -- Patch state tree to index this sensor by its label
         self:_log("Aliasing "..v.label.." -> "..k)
         self.state[v.label] = self.state[k]
      end
      return parse_table
   end
end

-- Construct a new core temperature monitor
function core_temp:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   sysfs._init(self, args)

   local filter_fn = filter_map[args.units:lower()]

   self:_add_endpoint('name', 0)
   self:_add_endpoint('temp*_label', 0, nil, label_filter_factory(self))
   self:_add_endpoint('temp*_{max,crit,crit_alarm}', 0, filter_fn, sensor_filter)
   self:_add_endpoint('temp*_input', self.poll_rate, filter_fn, sensor_filter)

   return self
end

return core_temp
