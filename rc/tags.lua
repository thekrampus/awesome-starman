-- Tag configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")

awful.layout.layouts = {
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

local tags = {
   { "prime.png",   awful.layout.suit.tile     },
   { "irc.png",     awful.layout.suit.tile     },
   { "net.png",     awful.layout.suit.tile     },
   { "jams.png",    awful.layout.suit.max      },
   { "games.png",   awful.layout.suit.tile.top },
   { "lambda.png",  awful.layout.suit.fair     },
   { "epsilon.png", awful.layout.suit.spiral   }
}
function add_tags_to_screen(s)
   local icons = beautiful.icondir or awful.get_awesome_icon_dir()
   for _, t in ipairs(tags) do
      awful.tag.add("", {
                       icon = icons .. t[1],
                       layout = t[2],
                       master_fill_policy = "master_width_factor",
                       gap_single_client = true,
                       gap = beautiful.useless_gap or 0,
                       screen = s
      })
   end
end
