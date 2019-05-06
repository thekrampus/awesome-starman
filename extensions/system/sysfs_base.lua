--- Abstract base for a sysfs monitor
local awful = require('awful')
local abc = require('abc')
local nifty = require('nifty')

local sysfs = abc:_subclass{
   _repr = 'SysFS Monitor'
}

-- shell command to resolve globs in an endpoint argument
local GLOB_CMD = "bash -c 'cd %s; for f in %s; do echo $f; done'"
-- shell command to poll endpoint values
-- NOTE: globs always resolve in alphabetical order
local POLL_CMD = "bash -c 'paste -s %s'"

local function monitor_factory(names, value_filter, table_filter)
   return function (out)
      local parse_table = {}
      local i = 1
      for value in out:gmatch("[^\n]*") do
         if names[i] ~= nil then
            if value_filter then
               value = value_filter(value)
            end
            parse_table[names[i]] = value
         end
         i = i + 1
      end
      if table_filter then
         parse_table = table_filter(parse_table)
      end
      return parse_table
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
-- @param value_filter Optional function to filter raw endpoint file
--                     value. Takes a raw value, returns a filtered
--                     value.
-- @param table_filter Optional function to filter the table of parsed
--                     endpoints & values.
function sysfs:_add_endpoint(endpoint, poll_rate, value_filter, table_filter)
   self._barrier:start()
   self:_log("Adding endpoint "..endpoint)

   local function glob_cb(names)
      -- if no names were found, we're done
      if #names == 0 then
         self._barrier:finish()
         return
      end

      self:_log("Found "..#names.." names for endpoint "..endpoint)
      -- set up polling for list of globbed files
      local cmd = POLL_CMD:format(self.sysfs_path .. endpoint)
      local poll_cb = monitor_factory(names, value_filter, table_filter)

      self:_add_poll(cmd, poll_cb, poll_rate)
      self._barrier:finish()
   end

   awful.spawn.easy_async(GLOB_CMD:format(self.sysfs_path, endpoint), glob_handler(glob_cb))
end

function sysfs:start()
   self._barrier:when_open(function() abc.start(self) end, 30)
   self:_log("Delaying `start` till initialization is complete.")
end

function sysfs:_init(args)
   assert(args.sysfs_path ~= nil, "Missing required argument `sysfs_path`.")
   abc._init(self, args)

   self._barrier = nifty.sync.barrier:new()
end

return sysfs
