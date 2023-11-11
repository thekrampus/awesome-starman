-- Utilities for taking screenshots with scrot
local awful   = require("awful")
local spawn   = require("awful.spawn")
local naughty = require("naughty")
local var     = require("rc.variables")

local scrot = {}

local scrot_cmd = "scrot"
local filename_pattern = var.screenshot_path .. "/" .. var.screenshot_filename_pattern

--- Capture the screen asynchronously using `scrot`
-- @param opts A table of optional arguments
-- @param opts.filename The output file
-- @param opts.select   Select a capture region interactively
-- @param opts.focused  Capture only the focused window
-- @param opts.monitor  Capture only the monitor with the given Xinerama index
-- @param opts.notify   Display a notification after saving
function scrot.screenshot(opts)
   opts = opts or {}
   local filename = opts.filename or filename_pattern
   local notify = opts.notify == nil and var.screenshot_notify or opts.notify

   local command = scrot_cmd .. " --exec 'echo $f' --file '" .. filename .. "'"
   if opts.select then
      command = command .. " --select --line " .. var.screenshot_select_style
   elseif opts.focused then
      command = command .. " --focused"
   elseif opts.monitor then
      command = command .. " --monitor " .. opts.monitor
   end

   local callback = function(out, err, _, code)
      if code ~= 0 then
         naughty.notify{
            preset=naughty.config.presets.critical,
            title="error saving screenshot",
            text=err .. "\ncommand: " .. command
         }
      elseif notify then
         naughty.notify{
            title="screenshot saved",
            text="written to " .. out
         }
      end
   end

   spawn.easy_async_with_shell(command, callback)
end

--- Capture the focused client
-- @param opts A table of optional arguments
-- @param opts.filename The output file
-- @param opts.notify   Display a notification after saving
function scrot.focused(opts)
   opts = opts or {}
   scrot.screenshot{
      filename=opts.filename,
      notify=opts.notify,
      focused=true
   }
end

--- Capture an interactively-selected region
-- @param opts A table of optional arguments
-- @param opts.filename The output file
-- @param opts.notify   Display a notification after saving
function scrot.select(opts)
   opts = opts or {}
   scrot.screenshot{
      filename=opts.filename,
      notify=opts.notify,
      select=true
   }
end

--- Capture the focused screen
-- @param opts A table of optional arguments
-- @param opts.filename The output file
-- @param opts.notify   Display a notification after saving
function scrot.screen(opts)
   opts = opts or {}
   local focused_screen = awful.screen.focused()
   -- rpk: I am PRETTY SURE that awesome indexes screens in the same order as Xinerama, but I can't confirm that.
   -- nonetheless this works on my machine :shrug:
   local monitor = focused_screen and focused_screen.index - 1 or 0
   scrot.screenshot{
      filename=opts.filename,
      notify=opts.notify,
      monitor=monitor
   }
end


return scrot
