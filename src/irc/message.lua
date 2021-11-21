---
-- Implementation of IRC server message parsing
-- initialization {{{
local constants = libs.constants
local ctcp =      libs.ctcp
local irc_debug = libs.debug
local misc =      libs.misc
local socket =    libs.socket
-- }}}

---
-- This module contains parsing functions for IRC server messages.
local message = {}

-- internal functions {{{
-- _parse {{{
--
-- Parse a server command.
-- @param str Command to parse
-- @return Table containing the parsed message. It contains:
--         <ul>
--         <li><i>from:</i>    The source of this message, in full usermask
--                             form (nick!user@host) for messages originating
--                             from users, and as a hostname for messages from
--                             servers</li>
--         <li><i>command:</i> The command sent, in name form if possible,
--                             otherwise as a numeric code</li>
--         <li><i>args:</i>    Array of strings corresponding to the arguments
--                             to the received command</li>
--
--         </ul>
function message._parse(str)
    -- low-level ctcp quoting {{{
    str = ctcp._low_dequote(str)
    -- }}}
    -- parse the from field, if it exists (leading :) {{{
    local from = ""
    if str:sub(1, 1) == ":" then
        local e
        e, from = socket.skip(1, str:find("^:([^ ]*) "))
        str = str:sub(e + 1)
    end
    -- }}}
    -- get the command name or numerical reply value {{{
    local command, argstr = socket.skip(2, str:find("^([^ ]*) ?(.*)"))
    local reply = false
    if command:find("^%d%d%d$") then
        reply = true
        if constants.replies[tonumber(command)] then
            command = constants.replies[tonumber(command)]
        else
            irc_debug._warn("Unknown server reply: " .. command)
        end
    end
    -- }}}
    -- get the args {{{
    local args = misc._split(argstr, " ", ":")
    -- the first arg in a reply is always your nick
    if reply then table.remove(args, 1) end
    -- }}}
    -- return the parsed message {{{
    return {from = from, command = command, args = args}
    -- }}}
end
-- }}}
-- }}}

return message
