--- Abstract base for a sysfs monitor
local awful = require("awful")
local gears = require("gears")

local base = {}
base.__index = base

-- shell command to resolve globs in an endpoint argument
local GLOB_CMD = "bash -c 'cd %s; for f in %s; do echo $f; done'"
-- shell command to poll endpoint values
-- NOTE: globs always resolve in alphabetical order
local POLL_CMD = "bash -c 'paste -s %s'"

local LOG_FMT = "[SYSFS %s] <%d>: %s"

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
         if names[i] ~= nil then
            update_cb(names[i], value)
         end
         i = i + 1
      end
   end
end

local function glob_handler(callback)
   return function (out, _, _, _)
      -- stdout will be empty on failure, so fail silently
      -- build a list of filenames in shell globbing order
      local names = {}
      for filename in out:gmatch("[^\n]+") do
         table.insert(names, filename)
      end

      callback(names)
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
-- @param endpoint A file name or glob to poll relative to this monitor's sysfs
--                 path.
-- @param rate The polling interval, in seconds. A rate of 0 will cause this
--             endpoint to be polled only once, immediately.
-- @param filter Optional function to filter raw endpoint file value. Takes a
--               raw value, returns a filtered value.
function base:with_endpoint(endpoint, rate, filter)
   self:_lock()
   rate = rate or DEFAULT_POLL_RATE
   self:_log("Adding endpoint "..endpoint)

   -- if a filter was given, it will be applied before calling self:_update
   local update_cb
   if filter ~= nil then
      update_cb = function(k, v) self:_update(k, filter(v)) end
   else
      update_cb = function(k, v) self:_update(k, v) end
   end

   local function glob_cb(names)
      -- if no names were found, we're done
      if #names == 0 then
         self:_release()
         return
      end

      self:_log("Found "..#names.." names for endpoint "..endpoint)
      -- set up polling for list of globbed files
      local cmd = POLL_CMD:format(self._sysfs_path .. endpoint)
      local monitor_cb = monitor_factory(names, update_cb)

      if rate == 0 then
         -- a rate of 0 signifies that the value should be polled once, now
         awful.spawn.easy_async(cmd, monitor_cb)
      else
         -- create a timer to run polling at the given rate
         local timer = gears.timer {
            timeout = rate,
            callback = function()
               self:_log("Polling endpoint "..endpoint)
               awful.spawn.easy_async(cmd, monitor_cb)
               return true
            end
         }
         self._timers[endpoint] = timer
      end

      self:_release()
   end

   awful.spawn.easy_async(GLOB_CMD:format(self._sysfs_path, endpoint), glob_handler(glob_cb))

   -- fluent interface
   return self
end

--- Add a callback to call when the value of an endpoint changes.
-- @param name The endpoint name.
-- @param callback Function to call with the new value.
function base:with_watcher(name, callback)
   if self._watchers[name] == nil then
      self._watchers[name] = {}
   end
   table.insert(self._watchers[name], callback)

   -- fluent interface
   return self
end

--- Get the current value associated with the given endpoint.
-- @param name The endpoint name. May be absolute or relative to `sysfs_path`
function base:get(name)
   return self._state[name]
end

--- Start asynchronous polling.
function base:start()
   local function start_cb()
      self:_log("Starting")
      for _,timer in pairs(self._timers) do
         timer:start()
      end
   end
   self:_log("`base:start` called; monitor will start after synchronization")
   self:_with_sync(30, start_cb)
end

--- Stop asynchronous polling.
function base:stop()
   self:_log("Stopping")
   for _,timer in pairs(self._timers) do
      timer:stop()
   end
end

function base:_update(name, value)
   if value ~= self._state[name] then
      self:_log("New value {"..value.."} for "..name)
      self._state[name] = value
      for _,fn in ipairs(self._watchers[name] or {}) do
         fn(value)
      end
   end
end

function base:_log(message)
   if self._verbose then
      print(LOG_FMT:format(self._sysfs_path, os.time(), message))
   end
end

function base:_lock()
   self._n_sync = self._n_sync + 1
end

function base:_release()
   self._n_sync = self._n_sync - 1
end

function base:_with_sync(timeout_s, callback)
   local timeout_time = os.time() + timeout_s
   gears.timer.start_new(
      0.5,
      function()
         if self._n_sync > 0 then
            if timeout_s >= 0 and os.time() >= timeout_time then
               print("Error: SYSFS monitor synchronization timed out!")
               if callback then
                  print("Callback has been dropped!")
               end
               return false
            end
         else
            if callback then
               callback()
            end
            return false
         end

         return true
      end
   )
end

--- Construct a new sysfs monitor.
-- Sysfs monitors have a root path (e.g. /sys/class/hwmon/hwmon0/) and will poll
-- the values of monitored endpoints relative to that root at regular intervals.
--
-- @param sysfs_path The root sysfs path of the device/interface to monitor.
function base.new(sysfs_path, verbose)
   local self = setmetatable({}, base)
   assert(sysfs_path ~= nil, "Missing required argument `sysfs_path`.")
   self._sysfs_path = sysfs_path
   self._verbose = verbose
   self._timers = {}
   self._watchers = {}
   self._filters = {}
   self._state = {}
   self._n_sync = 0

   return self
end

return base
