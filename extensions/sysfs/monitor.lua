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

function proxy.start()
   for _, v in __monitors do
      v:start()
   end
end

function proxy.stop()
   for _, v in _monitors do
      v:stop()
   end
end

return setmetatable(proxy, mt)
