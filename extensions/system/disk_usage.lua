--- Disk usage system monitor
local abc = require('abc')
local nifty = require('nifty')

local disk_usage = abc:_subclass{
   _repr = 'Disk Usage Monitor'
}

local DEFAULT_ARGS = {
   poll_rate = 30
}

local USAGE_CMD = "bash -c 'df -x tmpfs -x devtmpfs --output=target,source,fstype,size,used,avail | tail -n +2'"

local PARSE_PATTERN = string.rep('(%S+)%s*', 3) .. string.rep('(%d+)%s*',3) .. '\n'

function disk_usage:make_parser()
   local prev = {}
   return function(out)
      local parse_table = {}
      for target, source, fstype, size, used, avail in out:gmatch(PARSE_PATTERN) do
         local props = {
            target = target,
            fstype = fstype,
            size = size,
            used = used,
            avail = avail,
            d_used = 0
         }

         if prev[source] then
            props.d_used = props.used - prev[source].used
            prev[source] = nil
         else
            self:_on_new_disk(source, props)
         end
         parse_table[source] = props
      end
      for k,_ in pairs(prev) do
         -- since disks were removed from prev while parsing, any
         -- remaining must have been removed
         self:_on_rm_disk(k)
      end
      return parse_table
   end
end

function disk_usage:_on_new_disk(name, props)
   for _,fn in pairs(self._new_disk_listeners) do
      fn(name, props)
   end
end

function disk_usage:_on_rm_disk(name)
   for _,fn in pairs(self._rm_disk_listeners) do
      fn(name)
   end
end

--- Add a callback to call when a new disk is added.
-- @param callback Function to call with the new disk name and
--                 properties.
function disk_usage:add_new_disk_listener(callback)
   table.insert(self._new_disk_listeners, callback)
end

--- Add a callback to call when a disk is removed.
-- @param callback Function to call with the removed disk name.
function disk_usage:add_remove_disk_listener(callback)
   table.insert(self._rm_disk_listeners, callback)
end

function disk_usage:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   abc._init(self, args)
   self._new_disk_listeners = {}
   self._rm_disk_listeners = {}

   self:_add_poll(USAGE_CMD, self:make_parser(), self.poll_rate)
end

return disk_usage
