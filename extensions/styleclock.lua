local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")

--- Based on the text clock widget. (awful.widget.textclock)
local styleclock = { mt = {} }

local day_glyph = '☀'
-- local day_glyph = '☉'
-- local day_glyph = '⢾⡷'
local night_glyph = '☾'
-- local night_glyph = '✭'
-- local night_glyph = '☽'
-- local night_glyph = '☪'
-- local night_glyph = '⢾⡡'

local default_format = " %a %b %d <span color=\"white\">!G</span> %H:%M "

--- Create a styleclock widget, which draws the date and time with
--- time-dependent styling.
-- @param format Time/date format string.
--               "!G" is replaced with a day/night glyph.
-- @param timeout How often update the time. Default is 60.
-- @return A textbox widget.
function styleclock.new(format, timeout)
   local format = format or default_format
   local timeout = timeout or 60

   local w = textbox()

   local function styled_markup()
      local hour = tonumber(os.date("%H"))
      local glyph = day_glyph
      if hour<6 or hour>20 then
         glyph = night_glyph
      end
      local sub_format = string.gsub(format, '!G', glyph)

      w:set_markup(os.date(sub_format))
   end

   styled_markup()
   timer.start_new(timeout, styled_markup)

   return w
end

function styleclock.mt:__call(...)
   return styleclock.new(...)
end

return setmetatable(styleclock, styleclock.mt)
