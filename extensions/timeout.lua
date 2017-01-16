--- Decorates gears.timer to act as a UI element sleep timeout
local timer = require("gears.timer")

local timeout = {}
timeout.__index = timeout

function timeout:start_timeout()
   self.timer:start()
end

function timeout:stop_timeout()
   self.timer:stop()
end

function timeout:add_trigger(trigger)
   trigger:connect_signal("mouse::enter", function() self:stop_timeout() end)
   trigger:connect_signal("mouse::leave", function() self:start_timeout() end)
end

--- Construct a new timeout object
-- @param timeout_s Sleep timeout, in seconds
-- @param trigger Widget to trigger the timeout. Must emit mouse::enter and mouse::leave signals
-- @param on_timeout Callback for when the timeout fires
function timeout.new(timeout_s, trigger, on_timeout)
   local self = setmetatable({}, timeout)

   self.timer = timer({ timeout = timeout_s })
   self.timer:connect_signal("timeout", on_timeout)

   self:add_trigger(trigger)

   return self
end

setmetatable(timeout, {
                __call = function(cls, ...)
                   return cls.new(...)
                end
})

return timeout
