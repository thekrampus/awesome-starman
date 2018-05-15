-- Useful client extensions
local layout = require("awful.layout")
local capi   = { client = client }

local client_ext = {}

local saved_layout = layout.suit.floating

function client_ext.drag_float(c)
   local c = c or capi.client.focus

   if not c
      or c.fullscreen
      or c.type == "desktop"
      or c.type == "splash"
      or c.type == "dock"
   then
      return
   end

   local cur_layout = layout.get(c.screen)
   if cur_layout ~= layout.suit.floating then
      saved_layout = cur_layout
      layout.set(layout.suit.floating)
   end


end

function client_ext.drop_float(c)
   layout.set(saved_layout)

   saved_layout = layout.suit.floating
end


return client_ext
