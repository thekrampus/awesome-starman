-- Utilities (called from rc.lua)
local awful = require("awful")
local naughty = require("naughty")

-- {{{ Helper functions
function conf_debug()
   naughty.notify{title="HEY!", text="LISTEN!"}
end

-- Run a command and notify with output. Useful for debugging.
function run_and_notify(options)
   if type(options.cmd) ~= "string" then
      naughty.notify({text = "<span color\"red\">bad run_and_notify in rc.lua</span>"})
   else
      outstr = awful.util.pread(options.cmd .. " 2>&1")
      if options.notify then
         naughty.notify({title = options.cmd, text = outstr})
      end
   end
end

-- Recursively concat a table into a single formatted string.
function table_cat(t, depth)
   if depth == nil then
      depth = 0
   end
   indent = string.rep(" ", depth)
   if depth > 4 then
      return indent .. "[...]\n"
   end
   tcat = ""
   for k,v in pairs(t) do
      tcat = tcat .. indent .. tostring(k) .. " : "
      if type(v) == "table" then
         tcat = tcat .. "{\n" .. table_cat(v, depth+1) .. indent .. "}\n"
      else
         tcat = tcat .. tostring(v) .. "\n"
      end
   end
   return tcat
end
-- }}}
