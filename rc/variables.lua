-- Global variable settings (called from rc.lua)
local variables = {}

-- Name of the theme to use
variables.theme = "starman"

-- The default terminal and editor to run.
variables.terminal = "urxvt"
variables.editor = os.getenv("EDITOR") or "nano"
variables.editor_cmd = variables.terminal .. " -e " .. variables.editor

-- User home directory
variables.home_dir = os.getenv("HOME")

-- Auxillary monitor ID (usually 2)
variables.auxm = screen.count()

-- Enable titlebars?
variables.titlebars_enabled = false

return variables
