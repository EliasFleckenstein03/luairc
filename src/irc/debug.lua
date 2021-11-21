---
-- Basic debug output

---
-- This module implements a few useful debug functions for use throughout the
-- rest of the code.
local irc_debug = {}

-- defaults {{{
irc_debug.COLOR = true
-- }}}

-- local variables {{{
local ON = false
local outfile = io.output()
-- }}}

-- internal functions {{{
-- _message {{{
--
-- Output a debug message.
-- @param msg_type Arbitrary string corresponding to the type of message
-- @param msg      Message text
-- @param color    Which terminal code to use for color output (defaults to
--                 dark gray)
function irc_debug._message(msg_type, msg, color)
    if ON then
        local endcolor = ""
        if irc_debug.COLOR and outfile == io.stdout then
            color = color or "\027[1;30m"
            endcolor = "\027[0m"
        else
            color = ""
            endcolor = ""
        end
        outfile:write(color .. msg_type .. ": " .. msg .. endcolor .. "\n")
    end
end
-- }}}

-- _err {{{
--
-- Signal an error. Writes the error message to the screen in red and calls
-- error().
-- @param msg Error message
-- @see error
function irc_debug._err(msg)
    irc_debug._message("ERR", msg, "\027[0;31m")
    error(msg, 2)
end
-- }}}

-- _warn {{{
--
-- Signal a warning. Writes the warning message to the screen in yellow.
-- @param msg Warning message
function irc_debug._warn(msg)
    irc_debug._message("WARN", msg, "\027[0;33m")
end
-- }}}
-- }}}

-- public functions {{{
-- enable {{{
---
-- Turns on debug output.
function irc_debug.enable()
    ON = true
end
-- }}}

-- disable {{{
---
-- Turns off debug output.
function irc_debug.disable()
    ON = false
end
-- }}}

-- set_output {{{
---
-- Redirects output to a file rather than stdout.
-- @param file File to write debug output to
function irc_debug.set_output(file)
    outfile = assert(io.open(file))
end
-- }}}
-- }}}

return irc_debug
