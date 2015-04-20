-- quick and dirty script to remove BOM
-- 2015-04-20 18:51

local string_byte  = string.byte
local string_char  = string.char
local table_insert = table.insert

local function remove_bom(s)
    local r = {}
    for i = 1, # s do
        local c = string_byte(s, i)
        if c ~= 0xEF and c ~= 0xBB and c ~= 0xBF then
            table_insert(r, string_char(c))
        end
    end
    return table.concat(r)
end


local stdin = io.input()
local file = stdin:read('*a')
stdin:close()
local stdout = io.output()
stdout:write(remove_bom(file))
stdout:close()
