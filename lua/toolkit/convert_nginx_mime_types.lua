-- Thu 19:31 Mar 17
-- convert mime.types (nginx configure format) to Lua table

local types = {}

local sep = {}

local f = io.open('mime.types', 'rb')
while true do
    local line = f:read('l')
    if not line then
        break
    end
    local mime_type, p = line:match('^%s+([^%s]+)%s+(.+);$')
    if mime_type then
        local ext_names = {}
        for ext_name in p:gmatch('(%w+)') do
            table.insert(ext_names, string.format("'%s',", ext_name))
        end
        table.insert(types, {mime_type, ext_names})
    else
        table.insert(types, sep)
    end
end
f:close()

local output = io.open('mime_types.lua', 'wb')
output:write('return {\n')
for i, v in ipairs(types) do
    if v ~= sep then
        output:write(string.format(
            "    ['%s'] = { %s },\n", v[1], table.concat(v[2], ' ')
        ))
    else
        output:write('\n')
    end
end
output:write('}\n')
