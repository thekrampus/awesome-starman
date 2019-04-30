-- Wibar widget tray layout and configuration (called by rc.lua)
-- The widget tray is everything in the wibar after the taglist & tasklist
local wibox      = require("wibox")
local jammin     = require("jammin")
local styleclock = require("extensions.styleclock")
local cpu_meter  = require("extensions.cpu_meter")
local mem_meter  = require("extensions.mem_meter")
local disk_meter = require("extensions.disk_meter")

local tray = {}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()

-- Create jammin music-player widget
local mymusicbox = jammin()
mymusicbox:add_notify_handler("Spotify")

-- Create a textclock widget
local mytextclock = styleclock()

-- Create meters
-- local mycpumeter  = cpu_meter("Package id 0", {0,1,2,3}, 2)
local hwmon_root = '/sys/class/hwmon/hwmon1/'
local mycpumeter  = cpu_meter.new(
   {
      ['all']    = hwmon_root .. 'temp1_input',
      ['Core 0'] = hwmon_root .. 'temp2_input',
      ['Core 1'] = hwmon_root .. 'temp3_input',
      ['Core 2'] = hwmon_root .. 'temp4_input',
      ['Core 3'] = hwmon_root .. 'temp5_input'
   },
   2
)
local mymemmeter  = mem_meter(10, 5)
local mydiskmeter = disk_meter({
      disks = {"/dev/sdc2", "/dev/sdd1", "/dev/sdg1", "/dev/sda1"},
      timeout = 60
})

-- Create the base tray wibox, with elements common to the primary and secondary trays
local function base_tray(base)
   return wibox.layout.fixed.horizontal(mytextclock, base)
end

-- Create the widget tray for the primary screen.
function tray.primary(base)
   return wibox.layout.fixed.horizontal(mymusicbox.wibox,
                                        mycpumeter,
                                        mymemmeter,
                                        mydiskmeter,
                                        base_tray(base))
end

-- Create the widget tray for the secondary screen
function tray.secondary(base)
   return base_tray(base)
end

return tray
