#!/usr/bin/env lua

-- quick and dirty script to remove BOM
-- 2015-04-20 18:51

local string_byte  = string.byte
local string_char  = string.char
local table_insert = table.insert

local function remove_bom(s)
    if #s > 3 and s:sub(1, 3) == '\xef\xbb\xbf' then
        return true, s:sub(4, -1)
    else
        return false
    end
end

local function main(file_name)
    local file = io.open(file_name, 'rb')
    local fc = file:read('*a')
    io.close(file)
    local found_bom, r = remove_bom(fc)
    if found_bom then
        local tmpfile = os.tmpname()
        file = io.open(tmpfile, 'wb')
        file:write(r)
        file:close()
        os.rename(tmpfile, file_name)
        --os.execute('mv ' .. tmpfile .. ' ' .. file)
    end
end

if arg and arg[1] then
    main(arg[1])
end
