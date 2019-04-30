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

local function cpu_idx(cpu_id)
   local idx = cpu_id:match("cpu(%d+)")
   return idx
end

-- function cpu_meter:build_tooltip()
--    -- TODO
-- end

function cpu_meter:build_charts(color_fn)
   local usage = self._stats:get_tail(1)
   for cpu, use_pct in pairs(usage) do
      local chart = self._processors[cpu].chart
      if chart then
         chart:set_value(use_pct)
         chart.color = color_fn(cpu)
      end

      if self._ttip_graph then
         self._ttip_graph:add_value(use_pct, cpu_idx(cpu) + 1)
      end
   end
end

--- Create a new CPU meter widget
function cpu_meter.new(sensor_sysfs_map, timeout, layout, chart_theme)
   local self = setmetatable({}, cpu_meter)
   local use_sensors = (sensor_sysfs_map ~= nil)
   timeout = timeout or 1 -- default: 1 second
   self._stats = buffer.new(60)
   local theme = chart_theme or {}
   theme.tooltip = theme.tooltip or {}
   theme.tooltip.colors = theme.tooltip.colors or
      {
         beautiful.fg_normal,
         beautiful.fg_focus,
         "#ff4444",
         "#ffbb33",
         "#00C851",
         "#33b5e5",
         "#2BBBAD",
         "#4285F4",
         "#aa66cc",
         "#CC0000",
         "#FF8800",
         "#007E33",
         "#0099CC",
         "#00695c",
         "#0d47a1",
         "#9933CC"
      }

   -- build systray readout widget
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

   -- build tooltip graph
   self._ttip_graph = wibox.widget {
      max_value = 1,
      widget = wibox.widget.graph,
      background_color = theme.tooltip.background_color or beautiful.bg_focus,
      stack = true,
      stack_colors = theme.tooltip.colors
   }

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
      local n = 0
      local ttip_label = ""
      for cpu, core in pairs(core_map) do

         n = n + 1

         -- build systtray readout chart
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

         -- -- build tooltip graph
         -- local graph = wibox.widget {
         --    max_value = 1,
         --    widget = wibox.widget.graph,
         --    background_color = theme.tooltip.background_color or beautiful.bg_systray,
         --    color = theme.tooltip.color or beautiful.fg_normal
         -- }
         -- ttip_box:add(wibox.widget {
         --                 wibox.widget.textbox(cpu .. " "),
         --                 graph,
         --                 fill_space = true,
         --                 layout = wibox.layout.fixed.horizontal
         -- })

         ttip_label = ttip_label .. string.format('<span color="%s">%s</span> ',
                                                  theme.tooltip.colors[n],
                                                  cpu)

         -- object accessor
         self._processors[cpu] = {
            chart = chart,
            -- ttip = graph,
            core = core
         }
      end

      -- build tooltip
      local ttip_box = wibox.widget {
         self._ttip_graph,
         wibox.widget.textbox(ttip_label),
         layout = wibox.layout.fixed.vertical
      }

      -- monkey-patch textbox and add tooltip
      -- monkey-patch methods which will be called by the underlying tooltip
      ttip_box.set_markup = function(...) end
      local n_w = theme.tooltip.width or (2 * beautiful.menu_width)
      local n_h = theme.tooltip.height or (2 * beautiful.menu_height)
      print("width: " .. n_w)
      print("height: " .. n_h)
      ttip_box.get_preferred_size = function(...)
         return n_w, n_h
      end
      local ttip = awful.tooltip {
         objects = {self.widget},
      }
      ttip.textbox = ttip_box
      ttip.marginbox = wibox.container.margin(ttip_box, 5, 5, 3, 3)

      -- poll once to initialize widget
      poll()
      timer.start_new(timeout, poll)

      collectgarbage()
   end

   -- initialize with cpuinfo output
   awful.spawn.easy_async(info_cmd, init_cpuinfo)

   return self.widget
end

return cpu_meter
