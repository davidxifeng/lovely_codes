#!/usr/bin/env lua

-- quick and dirty script to remove BOM
-- 2015-04-20 18:51

local string_byte  = string.byte
local string_char  = string.char
local table_insert = table.insert

local function remove_bom(s)
    local r = {}

    local count = # s
    local i = 1

    while i <= count do

        local c = string_byte(s, i)
        if c == 0xEF and string_byte(s, i + 1) == 0xBB and string_byte(s, i + 2) == 0xBF then
            i = i + 3
        else
            i = i + 1
            table_insert(r, string_char(c))
        end

    end

    -- fix new line at eof
    if r[#r] ~= '\n' then
        table_insert(r, '\n')
    end

    return table.concat(r)
end


local stdin = io.input()
local file = stdin:read('*a')
stdin:close()
local stdout = io.output()
stdout:write(remove_bom(file))
stdout:close()
