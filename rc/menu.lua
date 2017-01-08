-- Menu configuration (called from rc.lua)
local menu = require("awful.menu")

local var = require("rc.variables")

return menu{ items = var.mainmenu }
