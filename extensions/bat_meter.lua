-- A widget to show battery status/events polled at regular intervals
local setmetatable = setmetatable

local awful   = require("awful")
local naughty = require("naughty")
local util    = require("rc.util")
local textbox = require("wibox.widget.textbox")
local timer   = require("gears.timer")

local bat_meter = { mt = {} }

local color_full  = "green"
local color_empty = "gray"
local color_std   = "white"
local color_low   = "orange"
local color_crit  = "red"
local color_crit_hex = "#ff0000"

local pct_low = 0.5
local pct_crit = 0.15
local crit_flag = false

local timeout_default = 5

local battery_animation = {'⡀⠀', '⣀⠀', '⣀⡀', '⣀⣀', '⣄⣀', '⣤⣀', '⣤⣄', '⣤⣤', '⣦⣤', '⣶⣤', '⣶⣦', '⣶⣶', '⣷⣶', '⣿⣶', '⣿⣷', '⣿⣿'}
local i_charge = 1

local readout_string = string.format('<span color="%s">%s</span><span color="%s">%s</span>',
                                     "%s", "%s",
                                     color_empty, "%3d%%")

local sysfs_path = "/sys/class/power_supply/"
local shell_cmd = string.format("cat %s/charge_now %s/status",
                                sysfs_path .. '%s',
                                sysfs_path .. '%s')

function bat_meter.readStatus(charge, charge_max, status)
   local charge_pct = charge / charge_max

   local readout = "["
   if status:match("Discharging") then
      readout = readout .. bat_meter.drainReadout(charge_pct)
   else
      readout = readout .. bat_meter.chargeReadout(charge_pct)
   end
   readout = readout .. "]"

   bat_meter.notify(charge_pct)

   return readout
end

function bat_meter.notify(charge_pct)
   if charge_pct < pct_crit then
      if not crit_flag then
         crit_flag = true
         naughty.notify{text="<b>POWER LEVEL CRITICAL</b>",
                        timeout=30,
                        fg=color_crit_hex,
                        border_color=color_crit_hex}
      end
   else
      crit_flag = false
   end
end

function bat_meter.chargeReadout(charge_pct)
   local p_pct = math.ceil(charge_pct * 100)
   local glyph = battery_animation[#battery_animation]
   if p_pct < 100 then
      glyph = battery_animation[i_charge]
      i_charge = (i_charge % #battery_animation) + 1
   end

   local readout = string.format(readout_string, color_full,
                                 glyph,
                                 p_pct)
   return readout
end

function bat_meter.drainReadout(charge_pct)
   local p_pct = math.ceil(charge_pct * 100)
   local i_glyph = math.ceil(charge_pct * #battery_animation)

   local col = color_std
   if charge_pct < pct_crit then
      col = color_crit
   elseif charge_pct < pct_low then
      col = color_low
   end

   local readout = string.format(readout_string, col,
                                 battery_animation[i_glyph],
                                 p_pct)
   return readout
end

function bat_meter.new(battery_id, timeout)
   local timeout = timeout or timeout_default

   local charge_max = tonumber(util.read(sysfs_path .. battery_id .. "/charge_full"))
   local poll_cmd = string.format(shell_cmd, battery_id, battery_id)
   local function poll_callback(widget, out, err, _, status)
      if status ~= 0 then
         print("\nNonzero exit code from bat_meter poll: " .. status)
         print(err)
         return
      end

      local charge_str, status = out:match("(.-)\n(.-)\n")
      local markup = bat_meter.readStatus(tonumber(charge_str), charge_max, status)
      widget:set_markup(markup)
   end

   local w = awful.widget.watch(poll_cmd, timeout, poll_callback)

   return w
end

function bat_meter.mt:__call(...)
   return bat_meter.new(...)
end

return setmetatable(bat_meter, bat_meter.mt)
