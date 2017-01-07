-- Tag configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")

local tags = {}

local tag_icons = awful.util.get_configuration_dir() .. "/tag_icons/"

-- Each element represents a tag: the name (not displayed), the icon, and the default layout
local mytags = {
   { "main", "prime.png",   awful.layout.suit.fair     },
   { "chat", "irc.png",     awful.layout.suit.tile     },
   { "inet", "net.png",     awful.layout.suit.fair     },
   { "jams", "jams.png",    awful.layout.suit.max      },
   { "game", "games.png",   awful.layout.suit.tile.top },
   { "work", "lambda.png",  awful.layout.suit.tile     },
   { "misc", "epsilon.png", awful.layout.suit.spiral   }
}

-- Usable layouts. Commented layouts are disabled.
tags.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   -- awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   -- awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   -- awful.layout.suit.magnifier,
   awful.layout.suit.corner.nw,
   -- awful.layout.suit.corner.ne,
   -- awful.layout.suit.corner.sw,
   -- awful.layout.suit.corner.se,
}

-- Add all standard to a screen
function tags.add_tags_to_screen(s)
   for _, t in ipairs(mytags) do
      awful.tag.add(t[1], {
                       icon = tag_icons .. t[2],
                       layout = t[3],
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
