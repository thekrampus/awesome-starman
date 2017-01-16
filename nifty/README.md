# nifty! -- handy extensions to [awesome][awesome]

## what

[awesome][awesome] is pretty neat. I wrote a couple of useful extensions to it, which I use in [my own configuration](/../../../awesome-starman) and [my media widget](/../../../awesome-jammin).

These are compatible with awesome 4. I make no guarantees re: backwards-compatibility with awesome 3.5.x or earlier.

some highlights:
* `timeout`, which can be used to deactivate widgets when they're not being used.
* `popup_widget`, a simple popup menu to wrap an arbitrary widget.
* All sorts of useful stuff
* :fire: HOT like FIRE :fire:

## but how
To use:
* `git clone` somewhere your config can read it, like `~/.config/awesome`
* Use it in your configuration:

    ```lua
    -- in your rc.lua:
    local nifty = require("nifty")
    local mypopup = nifty.popup_widget(my_widget, {timeout = 3})
    mypopup:show()
    ```

[awesome]: http://awesomewm.org/