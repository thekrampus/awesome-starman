-- A convenient way to automate some GUI tasks...
local x_macros = {}
local awful = require("awful")

local home_dir = os.getenv("HOME")
local macro_dir = home_dir .. "/x_macros/"
local hot_macro = macro_dir .. "hot_macro.sh"

function x_macros.build_menu()
   macromenu = {
      { "edit hotmacro", editor_cmd .. " " .. hot_macro }
   }

   for m in io.popen("ls " .. macro_dir):lines() do
      table.insert(macromenu, { m, function() awful.util.spawn(macro_dir .. m) end })
   end
   
   return macromenu
end

function x_macros.hot_macro()
   awful.util.spawn(hot_macro)
end

return x_macros
