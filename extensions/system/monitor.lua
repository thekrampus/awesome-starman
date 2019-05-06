--- Global container for a few standard active sysfs monitors

__monitors = __monitors or {}

local mt = {
   __index = function(t, k)
      return __monitors[k]
   end,

   __newindex = function(t, k, v)
      print('[sysfs monitor] <'..os.time()..'>: adding monitor '..tostring(k))
      __monitors[k] = v
   end
}

local proxy = {}

local function monitors()
   local k
   local function it(tbl)
      local v
      k,v = next(tbl, k)
      return v
   end
   return it, __monitors, nil
end

function proxy.start()
   for m in monitors() do
      m:start()
   end
end

function proxy.stop()
   for m in monitors() do
      m:stop()
   end
end

return setmetatable(proxy, mt)
