-- A background extension that polls the accelerometers to automatically re-orient the display
local setmetatable = setmetatable
local timer = require("gears.timer")
local awful = require("awful")
local bit = require("bit32")
local naughty = require("naughty")
local object = require("gears.object")
local imagebox = require("wibox.widget.imagebox")
local auto_rotate = { mt = {},
                      lock = false,
                      orientation = "none",
                      timeout = 5}

local sys_path = "/sys/dev/char/"
local script_path = "/home/rob/.local/src/rotate.sh"

local sign_mask = 0x8000

local accel_lim = 600

-- Time in s after which a read call should indicate failure
local last_heartbeat = nil
local suspend_delay = 2

local sig_handler = nil

local function cast_sign(n)
   return bit.bxor(n, sign_mask) - sign_mask
end

local function notify_error(msg)
   naughty.notify{preset = naughty.config.presets.low,
                  fg = "#ff0000",
                  title = "auto_rotate",
                  text = msg}
end

local function heartbeat()
   local last = last_heartbeat
   last_heartbeat = os.time()
   if last then
      local diff = last_heartbeat - last
      if diff >= auto_rotate.timeout + suspend_delay then
         notify_error("delayed by > " .. suspend_delay .. " seconds")
         auto_rotate.set_lock(true)
         return false
      end
   end
   return true
end

local function read_bus(fname)
   local dev = io.open(fname)
   if dev then
      raw = dev:read()
      io.close(dev)
   else
      notify_error("error reading system iio bus: " .. fname)
      auto_rotate.set_lock(true)
   end

   return raw
end

local function handle(x, y)
   if y < -accel_lim then
      auto_rotate.try_rotate("norm", auto_rotate.bg_landscape)
   elseif y > accel_lim then
      auto_rotate.try_rotate("flip", auto_rotate.bg_landscape)
   elseif x > accel_lim then
      auto_rotate.try_rotate("left", auto_rotate.bg_portrait)
   elseif x < -accel_lim then
      auto_rotate.try_rotate("right", auto_rotate.bg_portrait)
   end
end

local function try_poll()
   if not auto_rotate.lock then
      auto_rotate.poll()
   end
end

function auto_rotate.poll()
   local rX = read_bus(auto_rotate.x_dev)
   local rY = read_bus(auto_rotate.y_dev)

   if heartbeat() then
      local x = cast_sign(tonumber(rX))
      local y = cast_sign(tonumber(rY))

      handle(x, y)
   end
end

function auto_rotate.try_rotate(orientation, wallpaper)
   if orientation ~= auto_rotate.orientation then
      auto_rotate.orientation = orientation
      awful.spawn.with_shell(string.format("%s %s %s",
                                           script_path,
                                           orientation,
                                           wallpaper))
   end
end

function auto_rotate.set_lock(status)
   auto_rotate.lock = status
   last_heartbeat = nil
   sig_handler:emit_signal("property::lock")
end

function auto_rotate.toggle_lock()
   auto_rotate.lock = not auto_rotate.lock
   last_heartbeat = nil
   sig_handler:emit_signal("property::lock")
end

function auto_rotate.new(device, timeout, lock_callback)
   local beautiful = require("beautiful")
   auto_rotate.bg_landscape = beautiful.wallpaper
   auto_rotate.bg_portrait = beautiful.rotatedwallpaper
   local dev = sys_path .. device
   auto_rotate.x_dev = dev .. "/in_accel_x_raw"
   auto_rotate.y_dev = dev .. "/in_accel_y_raw"

   auto_rotate.icon_lock = beautiful.icondir .. "lock.png"
   auto_rotate.icon_unlock = beautiful.icondir .. "unlock.png"

   sig_handler = object()
   if lock_callback then
      sig_handler:connect_signal("property::lock", lock_callback)
   end

   sig_handler:connect_signal("property::lock", function() last_heartbeat = nil end)


   auto_rotate.timeout = timeout or auto_rotate.timeout

   timer {
      timeout = auto_rotate.timeout,
      autostart = true,
      callback = try_poll
   }

   local w = imagebox()

   local function update()
      if auto_rotate.lock then
         w:set_image(auto_rotate.icon_lock)
      else
         w:set_image(auto_rotate.icon_unlock)
      end
   end

   update()
   sig_handler:connect_signal("property::lock", update)
   w:buttons(awful.util.table.join(
                awful.button({ }, 1, auto_rotate.toggle_lock)
   ))

   return w
end

function auto_rotate.mt:__call(...)
   return auto_rotate.new(...)
end

return setmetatable(auto_rotate, auto_rotate.mt)
