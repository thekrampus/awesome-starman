--- CPU Core temperature sysfs monitor
local base = require("extensions.sysfs.base")

local core_temp = {}

local DEFAULT_ARGS = {
   sysfs_path = '/sys/class/hwmon/hwmon1/', -- default on my system
   rate = 5, -- poll every 5 seconds
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

-- Construct a new core temperature monitor
function core_temp.new(args)
   -- merge default args
   args = args or DEFAULT_ARGS
   for k, v in pairs(DEFAULT_ARGS) do
      if args[k] == nil then
         args[k] = v
      end
   end

   local filter_fn = filter_map[args.units:lower()]

   local self = base.new(args.sysfs_path, args.verbose)
   self:with_endpoint('temp*_label', 0)
   self:with_endpoint('temp*_{max,crit,crit_alarm}', 0, filter_fn)
   self:with_endpoint('temp*_input', args.rate, filter_fn)

   return self
end

return core_temp
