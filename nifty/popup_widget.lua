--- A wrapper for awful.menu that wraps a widget in a popup menu

local awful = require("awful")
local wibox = require("wibox")
local timeout = require("extensions.timeout")

local popup_widget = {}
popup_widget.__index = popup_widget

function popup_widget:show(...)
   if self._private.timeout then
      self._private.timeout:start_timeout()
   end
   self._private.menu:show(...)
end

function popup_widget:hide(...)
   if self._private.timeout then
      self._private.timeout:stop_timeout()
   end
   self._private.menu:hide(...)
end

function popup_widget:toggle(...)
   if self._private.menu.wibox.visible then
      self:hide(...)
   else
      self:show(...)
   end
end

function popup_widget.new(widget, args)
   local self = setmetatable({}, popup_widget)
   self._private = {}

   self._private.menu = awful.menu{ theme = args.theme }

   local wrapper = wibox.container.background(widget)

   if args.timeout then
      self._private.timeout = timeout(args.timeout, wrapper, function() self:hide() end)
   end

   local function make_menu()
      return {akey = nil, widget = wrapper, cmd = nil}
   end

   self._private.menu:add({ new = make_menu })

   return self
end

setmetatable(popup_widget, {
                __call = function(cls, ...)
                   return cls.new(...)
                end
})

return popup_widget
