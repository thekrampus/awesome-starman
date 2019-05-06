--- Memory usage system monitor
local abc = require('abc')
local nifty = require('nifty')

local mem_usage = abc:_subclass{
   _repr = 'Memory Usage Monitor'
}

local DEFAULT_ARGS = {
   poll_rate = 5
}

local USAGE_CMD = "free --bytes"

local function parse_usage(out)
   local mem_line, swap_line = out:match("Mem:%s*(.*)\n.*Swap:%s*(.*)$")

   local mem = {mem_line:match(("(%S+)%s*"):rep(6))}
   local swap = {swap_line:match(("(%S+)%s*"):rep(3))}
   return {
      mem_total = mem[1],
      mem_used = mem[2],
      mem_free = mem[3],
      mem_shared = mem[4],
      mem_buff = mem[5],
      mem_available = mem[6],
      swap_total = swap[1],
      swap_used = swap[2],
      swap_free = swap[3]
   }
end

function mem_usage:_init(args)
   args = nifty.util.merge_tables(args or {}, DEFAULT_ARGS)
   abc._init(self, args)

   self:_add_poll(USAGE_CMD, parse_usage, self.poll_rate)
end

return mem_usage
