-- Menu configuration (called from rc.lua)
local awful = require("awful")
local var  = require("rc.variables")
local freedesktop = require("freedesktop")

local _menu = {}
_menu.main = awful.menu{ items = var.mainmenu }
_menu.freedesktop = freedesktop.menu.build()
_menu.client = function() awful.menu.client_list({ theme = { width = 250 } }) end
return _menu
