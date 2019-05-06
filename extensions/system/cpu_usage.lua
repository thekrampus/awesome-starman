--- CPU usage system monitor
local abc = require("abc")
local nifty = require("nifty")

local cpu_usage = abc:_subclass{
   _repr = 'CPU Usage Monitor'
}

local DEFAULT_ARGS = {
   poll_rate = 2
}

local INFO_CMD  = "awk -v FS=':' '/^processor/ {printf $2 } /^core id/ {print $2}' /proc/cpuinfo"
local USAGE_CMD = "awk '/^cpu[[:digit:]]+/{ print $1, $5, ($2 + $3 + $4 + $5 + $6 + $7 + $8);}' /proc/stat"

local function parse_info(out)
   local core_map = {}
   for cpu, core in out:gmatch("(%d+)%s+(%d+)%s*\n") do
      core_map['cpu'..cpu] = 'Core '..core
   end
   return {core_map=core_map}
end

local function usage_parser_factory()
   local prev = {}
   return function(out)
      local stats = {}
      local report = {}
      for cpu, idle, total in out:gmatch("(%S+)%s+(%d+)%s+(%d+)%s*\n") do
         local busy = total - idle
         stats[cpu] = {
            busy = busy,
            total = total
         }

         -- usage over a polling cycle is the change in number of busy
         -- cycles over the change in number of total cycles
         if prev[cpu] then
            local d_busy = stats[cpu].busy - prev[cpu].busy
            local d_total = stats[cpu].total - prev[cpu].total
            if d_total == 0 then
               report[cpu] = 0
            else
               report[cpu] = d_busy / d_total
            end
         end
      end

      prev = stats
      return report
   end
end

function cpu_usage:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   abc._init(self, args)

   self._previous = {}

   self:_add_poll(INFO_CMD, parse_info, 0)
   self:_add_poll(USAGE_CMD, usage_parser_factory(), self.poll_rate)
end

return cpu_usage
