-----------------------------------
--   "Section 9" awesome theme   --
--          By krampus           --
-----------------------------------

-- required by the theme
local awful = require("awful")
local shape = require("gears.shape")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- {{{ Palette
bg1 = "#000000"
fg1 = "#2f3f3e"
bg2 = "#2c3135"
fg2 = "#5d616b"
hi1 = "#acb9c2"
hi2 = "#e4e5e4"
-- }}}

-- {{{ Main
theme = {}
theme.name = "section-9"
theme.confdir = awful.util.getdir("config") .. "/themes/" .. theme.name
theme.wallpaper = theme.confdir .. "/section-9-background.png"
theme.rotatedwallpaper = theme.confdir .. "/section-9-background-rotated.png"
theme.icondir = awful.util.getdir("config") .. "/tag_icons_mag/"
theme.tag_icons = false
-- }}}

-- {{{ Styles
-- theme.font       = "artwiz lemon 10px"
-- theme.font       = "shdw candy 11px"
-- theme.font       = "Tamzen 12px"
-- theme.font       = "ypn envypn bold 15px"
theme.font       = "artwiz snap.se 10px"

-- theme.font       = "URW Gothic Bold 10"

-- {{{ Colors
theme.fg_normal  = fg2
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
theme.border_gutter = dpi(8)
-- Weight of corner arrow
theme.border_weight = dpi(1)
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
theme.useless_gap = dpi(6)
theme.master_fill_policy = "expand"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
theme.taglist_bg_focus = fg2
theme.taglist_bg_occupied = bg2
-- theme.taglist_shape = shape.powerline
-- theme.tasklist_shape = shape.powerline
theme.taglist_spacing = 0
theme.tasklist_spacing = 0
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
theme.wibox_height = dpi(25)
theme.dock_width = dpi(164)
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width|border_padding]
theme.menu_height = dpi(25)
theme.menu_width  = dpi(160)
theme.menu_border_padding = dpi(4)
-- }}}

-- {{{ Icons
-- {{{ Taglist
-- theme.taglist_squares_sel   = theme.confdir .. "/taglist/squarefz.png"
-- theme.taglist_squares_unsel = theme.confdir .. "/taglist/squarefz.png"
-- theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme.confdir .. "/awesome-icon.png"
-- theme.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = theme.confdir .. "/layouts/tile.png"
theme.layout_tileleft   = theme.confdir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme.confdir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme.confdir .. "/layouts/fairv.png"
theme.layout_fairh      = theme.confdir .. "/layouts/fairh.png"
theme.layout_spiral     = theme.confdir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme.confdir .. "/layouts/dwindle.png"
theme.layout_max        = theme.confdir .. "/layouts/max.png"
theme.layout_fullscreen = theme.confdir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme.confdir .. "/layouts/magnifier.png"
theme.layout_floating   = theme.confdir .. "/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = theme.confdir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.confdir .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = theme.confdir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.confdir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.confdir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme.confdir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.confdir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.confdir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme.confdir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.confdir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.confdir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.confdir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme.confdir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.confdir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.confdir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
