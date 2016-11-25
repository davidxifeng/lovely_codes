#!/usr/bin/env lua

assert(_VERSION == 'Lua 5.3')

-- quick and dirty script to remove BOM
-- 2015-04-20 18:51

local string_byte  = string.byte
local string_char  = string.char
local table_insert = table.insert

local utf_8_bom = '\xef\xbb\xbf'

local function main(file_name)
    local file = io.open(file_name, 'rb')
    local bom = file:read(3)
    if bom == utf_8_bom then
      local tmpfile = os.tmpname()
      local tmp_file = io.open(tmpfile, 'wb')
      tmp_file:write(file:read 'a')
      file:close()
      tmp_file:close()
      os.rename(tmpfile, file_name)
    else
      file:close()
    end
end

if arg then
  for i = 1, # arg do
    main(arg[i])
  end
end
