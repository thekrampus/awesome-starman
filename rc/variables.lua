-- Global variable settings (called from rc.lua)
local personal = require("rc.personal") or {}

local variables = {}

-- Name of the theme to use
variables.theme = personal.theme or "default"

-- The default terminal and editor to run.
variables.terminal = personal.terminal or "xterm"
variables.editor = personal.editor or os.getenv("EDITOR") or "nano"
variables.editor_cmd = personal.editor_cmd or variables.terminal .. " -e " .. variables.editor

-- User home directory
variables.home_dir = personal.home_dir or os.getenv("HOME")

-- Auxillary monitor ID (usually 2)
variables.auxm = personal.lua or screen.count()

-- Enable titlebars?
variables.titlebars_enabled = personal.titlebars_enabled or false

return variables
