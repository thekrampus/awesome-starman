local setmetatable = setmetatable
local os = os
local spawn = require("awful.spawn")
local textbox = require("wibox.widget.textbox")
local tooltip = require("awful.tooltip")
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

-- useful constants...
local min_s = 60
local hour_s = min_s * 60
local day_s = hour_s * 24

local default_format = " %a %b %d <span color=\"white\">!G</span> %H:%M "

local tooltip_format = "last system update was <span color=\"white\">%s</span>ago"

local lastupdate_cmd = '/usr/bin/bash -c "grep -e \\"Running \'pacman.*-Sy\'\\" /var/log/pacman.log | tail -1"'

local function lastupdate_handler(ttip, stdout, stderr, exitreason, exitcode)
   if exitcode ~= 0 then
      print("styleclock: non-zero exit code from last-update call: " .. exitcode)
      print(stderr)
      return
   end

   local y, m, d, h, s = stdout:match("%[(%d+)-(%d+)-(%d+) (%d+):(%d+)%]")

   if y and m and d and h and s then
      local last_update = os.time{year=y, month=m, day=d, hour=h, min=m}
      local diff_s = os.difftime(os.time(), last_update)
      local days = diff_s // day_s
      diff_s = diff_s % day_s
      local hours = diff_s // hour_s
      diff_s = diff_s % hour_s
      local minutes = diff_s // min_s
      -- Called once a minute, so we don't care about seconds...

      local diffstring
      if days == 0 and hours == 0 and minutes == 0 then
         diffstring = "not very long "
      else
         local grammar_fmt = '%d %s%s%s '
         local function grammar(a, unit, b)
            if a > 0 then
               return grammar_fmt:format(a, unit, (a > 1 and 's' or ''), (b and ',' or ''))
            else
               return ''
            end
         end

         diffstring = grammar(days, "day", (hours + minutes) > 0)
         diffstring = diffstring .. grammar(hours, "hour", minutes > 0)
         diffstring = diffstring .. grammar(minutes, "minute", false)
      end

      ttip:set_markup(tooltip_format:format(diffstring))
   end
end

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

   local ttip = tooltip{objects = {w}, delay_show = 1}

   local function styled_markup()
      local hour = tonumber(os.date("%H"))
      local glyph = day_glyph
      if hour<6 or hour>20 then
         glyph = night_glyph
      end
      local sub_format = string.gsub(format, '!G', glyph)

      w:set_markup(os.date(sub_format))

      spawn.easy_async(lastupdate_cmd, function(...) lastupdate_handler(ttip, ...) end)
      return true
   end

   styled_markup()
   timer.start_new(timeout, styled_markup)

   return w
end

function styleclock.mt:__call(...)
   return styleclock.new(...)
end

return setmetatable(styleclock, styleclock.mt)
