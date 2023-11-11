-- Tag configuration (called from rc.lua)
local awful = require("awful")
local var   = require("rc.variables")

local tags = {}

local tag_icons = awful.util.get_configuration_dir() .. "/tag_icons/"

-- Add all standard to a screen
function tags.add_tags_to_screen(s)
   local default_layout = awful.layout.suit.tile
   local default_column_count = 1
   local default_master_count = 1
   local aspect_ratio = s.geometry.width / s.geometry.height

   if aspect_ratio > 2 then
      -- Use columnar layout on ultra-wide screens
      default_layout = awful.layout.suit.tile
      default_column_count = 4
      default_master_count = 0
   elseif aspect_ratio < 1 then
      -- Use vertically-tiling layout for portrait-orientation screens
      default_layout = awful.layout.suit.tile.top
   end

   for _, t in ipairs(var.tags) do
      awful.tag.add(t[1] or "tag", {
                       icon = t[2] and tag_icons .. t[2],
                       layout = t[3] or default_layout,
                       column_count = default_column_count,
                       master_count = default_master_count,
                       screen = s
      })
   end
end

-- Create a new volatile "transient" tag for a client
function tags.to_transient_tag(c)
   if c then
      local icon = tag_icons .. "epsilon.png"
      local tag = awful.tag.add("temp", {
                                 icon = icon,
                                 layout = awful.layout.suit.fair,
                                 screen = c.screen,
                                 volatile = true
      })
      c:tags({tag})
      tag:view_only()
   end
end

return tags
