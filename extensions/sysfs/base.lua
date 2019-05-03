--- Abstract base for a sysfs monitor
local awful = require("awful")
local gears = require("gears")

local base = {}

-- shell command to resolve globs in an endpoint argument
local GLOB_CMD = "bash -c 'for f in %s; do echo $f; done'"
-- shell command to poll endpoint values
-- NOTE: globs always resolve in alphabetical order
local POLL_CMD = "paste -s %s"

local DEFAULT_POLL_RATE = 10

local function monitor_factory(names, update_cb)
   return function (out, err, _, code)
      if code ~= 0 then
         print("Error polling endpoint:")
         print(err)
         return
      end

      local i = 1
      for value in out:gmatch("[^\n]*") do
         update_cb(names[i], value)
         i = i + 1
      end
   end
end

function base:_update(name, value)
   if value ~= self._state[name] then
      self._state[name] = value
      for _,fn in ipairs(self._watchers[name] or {}) do
         fn(value)
      end
   end
end

--- Add an endpoint to this sysfs monitor.
-- Endpoints are files relative to the monitor's sysfs root.  When the monitor
-- is started, the value at this endpoint will be polled at a regular rate. That
-- polled value may be accessed directly with this object's `get` method, or
-- callers may add a watcher to be called when the value changes.
--
-- To optimize I/O, instead of adding the name of a single file as an endpoint,
-- you may add a bash glob. Every file in a glob endpoint will be polled at
-- once. This also ensures that related endpoints aren't updated out-of-sync.
--
-- @param endpoint A file name or glob to poll.
-- @param rate The polling interval, in seconds. A rate of 0 will cause this
--             endpoint to be polled only once, immediately.
function base:add_endpoint(endpoint, rate)
   local qual_endpoint = self._sysfs_path .. endpoint
   rate = rate or DEFAULT_POLL_RATE

   -- resolve globs, building an ordered list of files
   local function ls_cb(out, _, _, _)
      -- stdout will be empty on failure, so fail silently
      if out:len() == 0 then
         return
      end

      -- build a list of filenames in shell globbing order
      local names = {}
      for filename in out:gmatch("[^\n]+") do
         table.insert(names, filename)
      end

      local cmd = POLL_CMD:format(qual_endpoint)
      local callback = monitor_factory(names, function(...) self:_update(...) end)

      if rate == 0 then
         -- a polling rate of 0 signifies that the value should be polled once,
         -- immediately
         awful.spawn.easy_async(cmd, callback)
      else
         -- create a timer to run polling at the given rate
         local timer = gears.timer {
            timeout = rate,
            callback = function()
               awful.spawn.easy_async(cmd, callback)
               return true
            end
         }
         self._timer[endpoint] = timer
      end
   end

   awful.spawn.easy_async(GLOB_CMD:format(qual_endpoint), ls_cb)

   return self
end

--- Add a callback to call when the value of an endpoint changes.
-- @param name The endpoint name.
-- @param callback Function to call with the new value.
function base:add_watcher(name, callback)
   if self._watchers[name] == nil then
      self._watchers[name] = {}
   end
   table.insert(self._watchers[name], callback)
end

--- Get the current value associated with the given endpoint.
-- @param name The endpoint name. May be absolute or relative to `sysfs_path`
function base:get(name)
   return self._state[name] or self._state[self._sysfs_path .. name]
end

-- Start asynchronous polling.
function base:start()
   for _,timer in ipairs(self._timers) do
      timer:start()
   end
end

--- Stop asynchronous polling.
function base:stop()
   for _,timer in ipairs(self._timers) do
      timer:stop()
   end
end

--- Construct a new sysfs monitor.
-- Sysfs monitors have a root path (e.g. /sys/class/hwmon/hwmon0/) and will poll
-- the values of monitored endpoints relative to that root at regular intervals.
--
-- @param sysfs_path The root sysfs path of the device/interface to monitor.
function base.new(sysfs_path)
   local self = setmetatable({}, base)
   assert(sysfs_path ~= nil, "Missing required argument `sysfs_path`.")
   if sysfs_path:sub(-1) ~= '/' then
      -- add trailing slash if not already present
      sysfs_path = sysfs_path .. '/'
   end
   self._sysfs_path = sysfs_path
   self._timers = {}
   self._state = {}

   return self
end

return base
