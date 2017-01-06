-- Tag configuration (called from rc.lua)
local awful = require("awful")
local beautiful = require("beautiful")

-- Custom layout patching
awful.layout.suit.tile = require("patch.tile")
awful.layout.suit.spiral = require("patch.spiral")
awful.layout.suit.max = require("patch.max")
awful.layout.suit.fair = require("patch.fair")

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
   {
      awful.layout.suit.floating,
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      --awful.layout.suit.tile.bottom,
      awful.layout.suit.tile.top,
      awful.layout.suit.fair,
      --awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral,
      --awful.layout.suit.spiral.dwindle,
      awful.layout.suit.max,
      --awful.layout.suit.max.fullscreen,
      --awful.layout.suit.magnifier
   }


-- Define a tag table which hold all screen tags.
local icons = beautiful.icondir
tags = {
   names = { "", "", "", "", "", "", "" },
   layout = { layouts[2], layouts[2], layouts[2], layouts[7], layouts[6], layouts[2], layouts[6] },
   icons = { icons .. "prime.png", icons .. "irc.png", icons .. "net.png", icons .. "jams.png", icons .. "games.png", icons .. "lambda.png", icons .. "epsilon.png"}
}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layout)
   for i, t in ipairs(tags[s]) do
      awful.tag.seticon(tags.icons[i], t)
   end
end

-- Tag manipulation buttons
globalbuttons = awful.util.table.join(globalbuttons,
                                      awful.button({ }, 8, awful.tag.viewnext),
                                      awful.button({ }, 9, awful.tag.viewprev)
)

-- Tag & layout management keys
globalkeys = awful.util.table.join(globalkeys,
                                   awful.key({ modkey, "Shift"   }, "[",   awful.tag.viewprev),
                                   awful.key({ modkey, "Shift"   }, "]",   awful.tag.viewnext),
                                   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
                                   awful.key({ modkey,           }, "l",   function () awful.tag.incmwfact( 0.05)    end),
                                   awful.key({ modkey,           }, "h",   function () awful.tag.incmwfact(-0.05)    end),
                                   awful.key({ modkey, "Shift"   }, "h",   function () awful.tag.incnmaster( 1)      end),
                                   awful.key({ modkey, "Shift"   }, "l",   function () awful.tag.incnmaster(-1)      end),
                                   awful.key({ modkey, "Control" }, "h",   function () awful.tag.incncol( 1)         end),
                                   awful.key({ modkey, "Control" }, "l",   function () awful.tag.incncol(-1)         end),
                                   awful.key({ modkey,           }, "Tab", function () awful.layout.inc(layouts,  1) end),
                                   awful.key({ modkey, "Shift"   }, "Tab", function () awful.layout.inc(layouts, -1) end)
)

-- Compute the maximum number of digit we need, limited to 9
local keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({ modkey }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            if tags[screen][i] then
                                               awful.tag.viewonly(tags[screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Control" }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            if tags[screen][i] then
                                               awful.tag.viewtoggle(tags[screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus and tags[client.focus.screen][i] then
                                               awful.client.movetotag(tags[client.focus.screen][i])
                                            end
                                      end),
                                      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus and tags[client.focus.screen][i] then
                                               awful.client.toggletag(tags[client.focus.screen][i])
                                            end
   end))
end
