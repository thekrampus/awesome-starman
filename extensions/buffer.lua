--- Synchronized circular data buffer

local buffer = {}
buffer.__index = buffer

--- Create a new synchronized circular data buffer.
-- @param capacity The limit on the number of items that may be added to the buffer.
--                 Once this limit is hit, adding a new item will delete the oldest in the buffer.
function buffer.new(capacity)
   local self = setmetatable({}, buffer)
   self._data = {}
   self._capacity = capacity
   self._lock = false
   self._tail = 1

   return self
end

--- Return the number of items in the buffer.
function buffer:getn()
   return #self._data
end

--- Add a new item to the buffer.
-- When the buffer has reached capacity, this will remove the oldest buffered item.
-- @param item The item to be added.
function buffer:push(item)
   self._data[self._tail] = item
   self._tail = (self._tail % self._capacity) + 1
end

--- Get the oldest item in the buffer.
function buffer:peek()
   if self:getn() < self._capacity then
      return self._data[1]
   else
      return self._data[self._tail]
   end
end

--- Return the contents of this buffer as an array.
-- In the resulting array, the oldest element is first.
function buffer:as_array()
   local arr = {}

   local n = 0
   for i = self._tail - 1, self._capacity + self._tail - 2 do
      local el = self._data[(i % self._capacity) + 1]
      if el then
         n = n + 1
         arr[n] = el
      end
   end

   return arr
end

--- Try to acquire the mutex lock on this buffer.
-- @return True if the lock could be acquired, false otherwise.
function buffer:try_lock()
   local initial = self._lock
   self._lock = true
   return ~initial
end

--- Release the mutex lock on this buffer.
-- @return True if this thread held the lock, false otherwise.
function buffer:release()
   local initial = self._lock
   self._lock = false
   return initial
end

--- Wait for the mutex lock on this buffer to become available, then immediately take it.
-- @param timeout Time in seconds to wait before returning exception.
-- @return True if the lock was acquired before timing out, false otherwise.
function buffer:wait_for_lock(timeout)
   local timeout_time = os.time() + timeout

   while self:try_lock() == false do
      if os.time() > timeout_time then
         return false
      end
   end
   return true
end

return buffer
