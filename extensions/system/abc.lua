--- Abstract base class for a system monitor
local awful = require('awful')
local gears = require('gears')
local nifty = require('nifty')

local LOG_FMT = "<%d> [%s] %s"

local abc = {
   _repr = 'Monitor'
}

local DEFAULT_ARGS = {
   verbose = false,
   poll_rate = 10
}

------------------------------------------------------------
--- Endpoint polling

local function default_error_handler(err, code)
   print("Error polling system properties <"..tostring(code)..">")
   print(tostring(err))
   return false
end

--- Add a polling routine.
-- This routine will run a shell command at a regular interval and
-- update the monitor's state with the parsed output.
--
-- @param cmd Shell command to run.
-- @param parser A function that takes the stdout output of `cmd` and
--               parses it into a table of monitor endpoints.
-- @param rate_s The polling interval, in seconds. A rate of 0 will
--                cause this endpoint to be polled only once, now.
-- @param error_handler Optional handler called if `cmd` exits with a
--                      non-zero code. Takes the stderr output and
--                      exit code as arguments.
function abc:_add_poll(cmd, parser, rate_s, error_handler)
   error_handler = error_handler or default_error_handler
   local function system_cb(out, err, _, code)
      if code ~= 0 then
         error_handler(err, code)
      else
         for k, v in pairs(parser(out)) do
            self:_update(k, v)
         end
      end
   end

   local function timer_cb()
      self:_log("Running poll: "..cmd)
      awful.spawn.easy_async(cmd, system_cb)
      return true
   end

   if rate_s == 0 then
      -- a rate of 0 signifies that the value should be polled once, now
      timer_cb()
   else
      -- create a timer to run polling at the given rate
      rate_s = rate_s or self.poll_rate
      self:_log("Will poll "..cmd.." every "..rate_s.." seconds.")
      local poll_timer = gears.timer {
         timeout = rate_s or self.poll_rate,
         callback = timer_cb,
         call_now = true
      }
      table.insert(self._polls, poll_timer)
   end
end

-- --- Has the given endpoint been defined?
-- -- @param name The endpoint name.
-- function abc:has(name)
--    return self:get(name) ~= nil
-- end

-- --- Get the current value associated with the given endpoint.
-- -- @param name The endpoint name.
-- function abc:get(name)
--    return self._state[name]
-- end

------------------------------------------------------------
--- Endpoint tree

local node = {}

--- Construct a new tree node
-- Children of a node may be indexed directly from the parent node,
-- like `parent.child`. Indexing a child which does not exist will
-- create it. Be careful when iterating!
function node._new(monitor)
   local new = {
      _monitor = monitor,
      _children = {},
      _listeners = {}
   }
   setmetatable(
      new,
      {
         __index = function(t, k)
            if node[k] then
               return node[k]
            elseif k:match('^_') then
               return nil
            else
               if not t._children[k] then
                  t._children[k] = node._new(monitor)
               end
               return t._children[k]
            end
         end
      }
   )
   return new
end

--- Has this node been defined?
function node:defined()
   if self._value then
      return true
   else
      for _,v in pairs(self._children) do
         if v:is_defined() then
            return true
         end
      end
      return false
   end
end

--- Get the value at this node
function node:get()
   if self._value then
      return self._value
   else
      local tab = {}
      for k, v in pairs(self._children) do
         tab[k] = v:get()
      end
      return tab
   end
end

function node:_notify_listeners(value)
   for _,fn in pairs(self._listeners) do
      fn(value)
   end
end

function node:_update(value)
   if type(value) == "table" then
      local flag = false

      -- add and update children
      for k, v in pairs(value) do
         local changed = self[k]:_update(v)
         flag = flag or changed
      end

      -- if any children changed, notify listeners
      if flag then
         self:_notify_listeners(value)
         return true
      else
         return false
      end
   else
      if self._value ~= value then
         self:_notify_listeners(value)
         self._value = value
         return true
      else
         return false
      end
   end
end

--- Add a callback to call when the value of this endpoint changes.
-- @param listener Function to call with the new value.
function node:add_listener(listener)
   table.insert(self._listeners, listener)
end

--- Update this monitor's state with a new value for a name
-- @param name The endpoint name.
-- @param value The new value to assign to the endpoint.
function abc:_update(name, value)
   if self.state[name]:_update(value) then
      self:_log("New value {"..tostring(value).."} for "..name)
   end
end

--- Start asynchronous polling.
function abc:start()
   self:_log("Starting")
   for timer in self:polls() do
      timer:start()
   end
end

--- Stop asynchronous polling.
function abc:stop()
   self:_log("Stopping")
   for timer in self:polls() do
      timer:stop()
   end
end

------------------------------------------------------------
--- Monitor iterators

local function _kv_iter(tab, keys)
   local k, v
   local function _iter(t)
      k,v = next(t, k)
      if keys then return k else return v end
   end
   return _iter, tab, nil
end

function abc:names()
   return _kv_iter(self.state, true)
end

function abc:polls()
   return _kv_iter(self._polls, false)
end

function node:matches(pattern)
   local function _iter(t, name)
      local value
      repeat
         name, value = next(t, name)
         if not name then
            return nil
         end
      until string.match(name, pattern)
      return name, value
   end
   return _iter, self._children, nil
end

------------------------------------------------------------
--- Monitor utilities

function abc:_log(message)
   if self.verbose then
      print(LOG_FMT:format(os.time(), self._repr, message))
   end
end

--- Subclass metaconstructor.
-- @param args Subclass variables
function abc:_subclass(args)
   args = args or {}
   args._parent = self
   return setmetatable(
      args,
      {
         __index = self,
         __call = function(...) self.new(self, ...) end
      }
   )
end

--- Create a new system monitor.
-- System monitors poll the values of system properties at regular
-- intervals.
function abc:new(args)
   local new = setmetatable({}, self)
   self.__index = self

   -- _init should be redefined by subclasses
   new:_init(args)

   return new
end

--- Initialize the system monitor
function abc:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   nifty.util.merge_in_place(self, args)

   self.state = node._new(self)
   self._polls = {}
end

return abc:_subclass()
