-- A widget to show battery status/events polled at regular intervals
local setmetatable = setmetatable
local util = require("rc.util")
local textbox = require("wibox.widget.textbox")
local capi = { timer = timer }
local bat_meter = { mt = {} }

local color_full = "green"
local color_empty = "gray"
local color_std = "white"
local color_low = "orange"
local color_crit = "red"

-- Width of usage meter, in glyphs, for the battery status.
local total_width_default = 6

-- Memory usage greater than this percent will be rendered in color_high
local pct_low = 0.5
local pct_crit = 0.15

local timeout_default = 5

local battery_glyph = ':'
local charge_glyph = '-'
local plug_glyph = '{'

local readout_string = string.format('<span color="%s">%s</span><span color="%s">%s</span>',
                                     "%s", "%s",
                                     color_empty, "%s")

function bat_meter.readStatus(syspath, total_width)
   local charge = tonumber(util.read(syspath .. "/charge_now"))
   local charge_max = tonumber(util.read(syspath .. "/charge_full"))
   local status = util.read(syspath .. "/status")

   local charge_pct = charge / charge_max

   local readout = "["
   if status:match("Discharging") then
      readout = readout .. bat_meter.drainReadout(charge_pct, total_width)
   else
      readout = readout .. bat_meter.chargeReadout(charge_pct, total_width)
   end
   readout = readout .. "]"
   return readout
end

function bat_meter.chargeReadout(charge_pct, total_width)
   local n_charge = math.floor(total_width * charge_pct)
   local n_empty = total_width - n_charge - 1

   local readout = string.format(readout_string, color_full,
                                 (charge_glyph):rep(n_charge) .. plug_glyph,
                                 (battery_glyph):rep(n_empty))
   return readout
end

function bat_meter.drainReadout(charge_pct, total_width)
   local n_charge = math.floor(total_width * charge_pct)
   local n_empty = total_width - n_charge

   local col = color_std
   if charge_pct < pct_low then
      col = color_low
   elseif charge_pct < pct_crit then
      col = color_crit
   end

   local readout = string.format(readout_string, col,
                                 (battery_glyph):rep(n_charge),
                                 (battery_glyph):rep(n_empty))
   return readout
end

function bat_meter.new(battery_id, total_width, timeout)
   local timeout = timeout or timeout_default
   local total_width = total_width or total_width_default

   local w = textbox()
   local timer = capi.timer { timeout = timeout }

   function poll()

      local syspath = "/sys/class/power_supply/" .. battery_id
      local markup = bat_meter.readStatus(syspath, total_width)

      w:set_markup(markup)
   end

   timer:connect_signal("timeout", poll)
   timer:start()
   timer:emit_signal("timeout")
   return w
end

function bat_meter.mt:__call(...)
   return bat_meter.new(...)
end

return setmetatable(bat_meter, bat_meter.mt)
