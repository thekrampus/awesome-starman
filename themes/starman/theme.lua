-----------------------------------
--    "Starman" awesome theme    --
--          By krampus           --
-- Based on Zenburn by Adrian C. --
-----------------------------------

-- required by the theme
local awful = require("awful")

-- {{{ Pallette
bg1 = "#2a2529"
fg1 = "#3f4e53"
bg2 = "#393333"
fg2 = "#607c88"
hi1 = "#a19b9b"
hi2 = "#c4c0c0"
-- }}}

-- {{{ Main
theme = {}
theme.name = "starman"
theme.confdir = awful.util.getdir("config") .. "/themes/" .. theme.name
theme.wallpaper = theme.confdir .. "/starman-background-3-big.png"
theme.smallpaper = theme.confdir .. "/starman-background-3.png"
theme.icondir = awful.util.getdir("config") .. "/tag_icons/"
-- }}}

-- {{{ Styles
theme.font      = "lemon,profont 10px"

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
theme.border_width  = 2
theme.border_normal = bg1
theme.border_focus = bg1
-- theme.border_normal = "[0]#000000"
-- theme.border_focus  = "[0]#000000"
theme.border_marked = theme.bg_urgent

-- Transparent padding
theme.useless_gap = 15
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = bg2
theme.titlebar_bg_normal = bg1
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
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width|border_padding]
theme.menu_height = 15
theme.menu_width  = 100
theme.menu_border_padding = 4
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
theme.layout_cornernw   = theme.confdir .. "/layouts/cornernw.png"
theme.layout_cornerne   = theme.confdir .. "/layouts/cornerne.png"
theme.layout_cornersw   = theme.confdir .. "/layouts/cornersw.png"
theme.layout_cornerse   = theme.confdir .. "/layouts/cornerse.png"
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
