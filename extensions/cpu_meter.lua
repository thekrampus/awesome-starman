-- A widget to poll and display useful cpu temperature & usage info
local awful   = require("awful")
local wibox   = require("wibox")
local timer   = require("gears.timer")
local beautiful = require("beautiful")

local buffer  = require("extensions.buffer")

local cpu_meter = {}
cpu_meter.__index = cpu_meter

local info_cmd  = "awk -v FS=':' '/^processor/ {printf $2 } /^core id/ {print $2}' /proc/cpuinfo"
local usage_cmd = "awk '/^cpu[0-9]/{ print $1, $5, ($2 + $3 + $4 + $5 + $6 + $7 + $8);}' /proc/stat"

local summary_fmt = '<span color="%s">%d°C</span>'

local color_normal   = "gray"
local color_elevated = "white"
local color_high     = "orange"
local color_crit     = "red"

-- Temperature thresholds. These can be provided by sensors,
-- or alternately hardcoded since they're unlikely to change...
local temp_elevated = 50
local temp_max      = 80
local temp_crit     = 100

-- Usage thresholds. An alternative to coloring by temperature.
local usage_elevated = 50
local usage_max      = 75
local usage_crit     = 98

local function delta_usage(prev, new)
   local usage = {}

   for k,v in pairs(new) do
      local d_used = v['used'] - prev[k]['used']
      local d_total = v['total'] - prev[k]['total']
      if d_total == 0 then
         usage[k] = 0
      else
         usage[k] = (d_used / d_total)
      end
   end

   return usage
end

local function color_by_level(input, elevated, max, crit)
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

local function color_by_temp(input)
   return color_by_level(input, temp_elevated, temp_max, temp_crit)
end

local function color_by_usage(input)
   return color_by_level(input, usage_elevated, usage_max, usage_crit)
end

local function parse_sensors(out, sensor_ids)
   local core_temps = {}

   local i = 0
   for ln in out:gmatch("[^\n]+") do
      i = i + 1
      local core_id = sensor_ids[i]
      if core_id then
         core_temps[core_id] = ln / 1000.0
      end
   end

   return core_temps
end

local function parse_usage(out)
   local data = {}

   for ln in out:gmatch("[^\n]+") do
      local core, idle, total = ln:match("(%S+)%s+(%S+)%s+(%S+)")
      data[core] = {
         total = total,
         used  = total - idle
      }
   end

   return data
end

local function parse_cpuinfo(out)
   local core_map = {}

   for ln in out:gmatch("[^\n]+") do
      local processor, core_id = ln:match("(%d+)%s*(%d+)")
      core_map['cpu' .. processor] = 'Core ' .. core_id
   end

   return core_map
end

function cpu_meter:build_charts(color_fn)
   local usage = self._stats:get_tail(1)
   for cpu, use_pct in pairs(usage) do
      local chart = self._processors[cpu].chart
      if chart then
         chart:set_value(use_pct)
         chart.color = color_fn(cpu)
      end
   end
end

--- Create a new CPU meter widget
function cpu_meter.new(sensor_sysfs_map, timeout, layout, chart_theme)
   local self = setmetatable({}, cpu_meter)
   local use_sensors = (sensor_sysfs_map ~= nil)
   timeout = timeout or 1 -- default: 1 second
   local theme = chart_theme or {}
   self._stats = buffer.new(60)

   local chart_box = wibox.widget {
      layout = wibox.layout.fixed.horizontal
   }

   self.widget = wibox.widget {
      wibox.widget.textbox("["),
      chart_box,
      wibox.widget.textbox("]"),
      layout = layout or wibox.layout.fixed.horizontal
   }

   if use_sensors and sensor_sysfs_map['all'] then
      self.widget:insert(2, wibox.widget.textbox("|"))
      local summary_box = wibox.widget.textbox()
      self.widget:insert(2, summary_box)
      self._set_summary = function(...) summary_box:set_markup(...) end
   end

   -- read each sensor sysfs node in order when polling sensors
   local sensor_cmd = "cat"
   local sensor_ids = {}
   for id,sysfs in pairs(sensor_sysfs_map) do
      table.insert(sensor_ids, id)
      sensor_cmd = sensor_cmd .. " " .. sysfs
   end

   -- async sensor callback
   local function sensor_callback(out, err, _, code)
      if code ~= 0 then
         print("\nError polling hardware sensors: " .. code)
         print(err)
         return
      end

      local core_temps = parse_sensors(out, sensor_ids)

      if core_temps['all'] then
         -- build summary box
         local all_temp = core_temps['all']
         local all_color = color_by_temp(all_temp)
         local markup = summary_fmt:format(all_color, math.floor(all_temp))
         self._set_summary(markup)
      end

      self:build_charts(function(id)
            return color_by_temp(
               core_temps[self._processors[id].core]
            )
      end)
   end

   -- async usage callback
   local function usage_callback(out, err, _, code)
      if code ~= 0 then
         print("\nError getting CPU usage: " .. code)
         print(err)
         return
      end

      local usage_data = parse_usage(out)
      if self._stats:wait_for_lock(5) then
      -- if true then
         if self._prev then
            local usage = delta_usage(self._prev, usage_data)
            self._stats:push(usage)

            if use_sensors then
               awful.spawn.easy_async(sensor_cmd,
                                      function(...)
                                         sensor_callback(...)
                                         self._stats:release()
                                      end
               )
            else
               self:build_charts(function(id) return color_by_usage(usage[id]) end)
               self._stats:release()
            end
         else
            self._stats:release()
         end

         self._prev = usage_data
      end

      collectgarbage()
   end

   -- async polling timer callback
   local function poll()
      awful.spawn.easy_async(usage_cmd, usage_callback)
      return true
   end

   -- initialize based on output of cpuinfo
   local function init_cpuinfo(out, err, _, code)
      if code ~= 0 then
         print("\nError initializing cpu_meter: " .. code)
         print(err)
         return
      end

      local core_map = parse_cpuinfo(out)

      self._processors = {}
      for cpu, core in pairs(core_map) do
         local chart = wibox.widget {
            max_value = 1,
            value = 0,
            margins = { top=1, left=3, right=3 } or theme.margins,
            widget = wibox.widget.progressbar,
            background_color = theme.background_color or beautiful.bg_systray
         }
         chart_box:add(
            wibox.widget {
               chart,
               forced_width = 4 or theme.forced_width,
               direction = 'east',
               layout = wibox.container.rotate
            }
         )
         self._processors[cpu] = {
            chart = chart,
            core = core
         }
      end

      -- poll once to initialize widget
      poll()
      timer.start_new(timeout, poll)

      collectgarbage()
   end
   awful.spawn.easy_async(info_cmd, init_cpuinfo)


   return self.widget
end

return cpu_meter
