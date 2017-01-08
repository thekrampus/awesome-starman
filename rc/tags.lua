-- Tag configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")

local var = require("rc.variables")

local tags = {}

local tag_icons = awful.util.get_configuration_dir() .. "/tag_icons/"

-- Add all standard to a screen
function tags.add_tags_to_screen(s)
   for _, t in ipairs(var.tags) do
      awful.tag.add(t[1] or "tag", {
                       icon = t[2] and tag_icons .. t[2],
                       layout = t[3] or awful.layout.suit.tile,
                       master_fill_policy = "master_width_factor",
                       gap_single_client = true,
                       gap = beautiful.useless_gap or 0,
                       screen = s
      })
   end
end

-- Create a new volatile "transient" tag for a client
function tags.to_transient_tag(c)
   if c then
      local icon = c.icon or tag_icons .. "epsilon.png"
      local tag = awful.tag.add("temp", {
                                 icon = icon,
                                 layout = awful.layout.suit.fair,
                                 master_fill_policy = "master_width_factor",
                                 gap_single_client = true,
                                 gap = beautiful.useless_gap or 0,
                                 screen = c.screen,
                                 volatile = true
      })
      c:tags({tag})
      tag:view_only()
   end
end

return tags
