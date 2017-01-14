-- Wibar widget tray layout and configuration (called by rc.lua)
-- The widget tray is everything in the wibar after the taglist & tasklist
local wibox = require("wibox")

local jammin = require("jammin")
local styleclock = require("extensions.styleclock")
local cpu_meter = require("extensions.cpu_meter")
local mem_meter = require("extensions.mem_meter")

local tray = {}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- Create jammin music-player widget
local mymusicbox = jammin()

-- Create a textclock widget
local mytextclock = styleclock()

-- Create cpu_meter and mem_meter widgets
local mycpumeter = cpu_meter("Physical id 0", {0,1,2,3}, 2)
local mymemmeter = mem_meter(10, 5)

-- Create the base tray wibox, with elements common to the primary and secondary trays
local function base_tray(base)
   return wibox.layout.fixed.horizontal(mytextclock, base)
end

-- Create the widget tray for the primary screen.
function tray.primary(base)
   return wibox.layout.fixed.horizontal(mymusicbox,
                                        mycpumeter,
                                        mymemmeter,
                                        base_tray(base))
end

-- Create the widget tray for the secondary screen
function tray.secondary(base)
   return base_tray(base)
end

return tray
