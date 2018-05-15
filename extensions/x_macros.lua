-- A convenient way to automate some GUI tasks...
local awful = require("awful")
local var   = require("rc.variables")

local x_macros = {}

local macro_dir = var.home_dir .. "/x_macros/"
local hot_macro = macro_dir .. "hot_macro.sh"

function x_macros.build_menu()
   local macromenu = {
      { "edit hotmacro", var.editor_cmd .. " " .. hot_macro }
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
