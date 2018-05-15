-----------------------------------
--    "Starman" awesome theme    --
--          By krampus           --
-- Based on Zenburn by Adrian C. --
-----------------------------------

-- required by the theme
local awful = require("awful")
local shape = require("gears.shape")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()
local dpi = xresources.apply_dpi

-- {{{ Palette
-- Primary
local bg1 = xrdb.background
local fg1 = xrdb.foreground
local bg2 = xrdb.color0
local fg2 = xrdb.color8
local bg3 = xrdb.color1
local fg3 = xrdb.color9
local hi1 = xrdb.color7
local hi2 = xrdb.color15
-- }}}

-- {{{ Main
local theme = {}
theme.name = "starman"

local theme_dir = awful.util.get_configuration_dir() .. "/themes/" .. theme.name

theme.font      = "lemon,profont 10px"
-- }}}

-- {{{ Wallpaper
function theme.wallpaper(s)
   local size = s.geometry.width * s.geometry.height
   if size <= 1280 * 1024 then
      return theme_dir .. "/starman-background-3-small.png"
   elseif size <= 1920 * 1080 then
      return theme_dir .. "/starman-background-3.png"
   else
      return theme_dir .. "/starman-background-3-big.png"
   end
end
-- }}}

-- {{{ Colors
theme.fg_normal  = fg1
theme.fg_focus   = hi1
theme.fg_urgent  = hi2
theme.bg_normal  = bg1
theme.bg_focus   = bg2
theme.bg_urgent  = hi1
theme.bg_systray = bg1
-- }}}

-- {{{ Borders
theme.border_width  = dpi(2)
theme.border_normal = bg1
theme.border_focus = bg1
theme.border_marked = theme.bg_urgent

-- Smart borders
-- Color for smart border on focused client
theme.border_smart = theme.fg_urgent
-- Size of gap between client and corner arrow
theme.border_gutter = dpi(4)
-- Weight of corner arrow
theme.border_weight = dpi(2)
-- Weight of side strings
theme.border_string = 0
-- Size of corner arrow
theme.border_arrow = dpi(16)
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = bg2
theme.titlebar_bg_normal = bg1
-- }}}

-- {{{ Tags
theme.gap_single_client = true
-- theme.useless_gap = dpi(15)
theme.useless_gap = dpi(10)
theme.master_fill_policy = "expand"
-- }}}

-- {{{ Taglist & Tasklist
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
theme.taglist_bg_focus       = fg1
theme.taglist_bg_occupied    = bg2
theme.taglist_bg_volatile    = bg3
theme.taglist_fg_volatile    = fg3
theme.taglist_shape          = shape.powerline
theme.taglist_shape_volatile = shape.hexagon
theme.tasklist_shape         = shape.powerline

theme.taglist_spacing        = -6
theme.tasklist_spacing        = -6

-- theme.taglist_squares_sel   = theme_dir .. "/taglist/squarefz.png"
-- theme.taglist_squares_unsel = theme_dir .. "/taglist/squarefz.png"
-- theme.taglist_squares_resize = "false"
-- }}}

-- {{{ widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
-- theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme_dir .. "/awesome-icon.png"
-- theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
theme.notify_icon_size_max       = dpi(32)
-- }}}

-- {{{ Layout
theme.layout_tile       = theme_dir .. "/layouts/tile.png"
theme.layout_tileleft   = theme_dir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme_dir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme_dir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme_dir .. "/layouts/fairv.png"
theme.layout_fairh      = theme_dir .. "/layouts/fairh.png"
theme.layout_spiral     = theme_dir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme_dir .. "/layouts/dwindle.png"
theme.layout_max        = theme_dir .. "/layouts/max.png"
theme.layout_fullscreen = theme_dir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme_dir .. "/layouts/magnifier.png"
theme.layout_floating   = theme_dir .. "/layouts/floating.png"
theme.layout_cornernw   = theme_dir .. "/layouts/cornernw.png"
theme.layout_cornerne   = theme_dir .. "/layouts/cornerne.png"
theme.layout_cornersw   = theme_dir .. "/layouts/cornersw.png"
theme.layout_cornerse   = theme_dir .. "/layouts/cornerse.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = theme_dir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme_dir .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme_dir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme_dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme_dir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme_dir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme_dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme_dir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme_dir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme_dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme_dir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme_dir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme_dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme_dir .. "/titlebar/maximized_normal_inactive.png"
-- }}}

return theme
