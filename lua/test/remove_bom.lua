#!/usr/bin/env lua

--assert(_VERSION == 'Lua 5.3')

-- quick and dirty script to remove BOM
-- 2015-04-20 18:51
--
-- Fri 16:29 Dec 09 2016
-- dos2unix也可以去掉bom,如果只想去bom保留换行,还可以简单地再次调用unix2dos

local string_byte  = string.byte
local string_char  = string.char
local table_insert = table.insert

local utf_8_bom = '\xef\xbb\xbf'

local function main(file_name)
  local file = io.open(file_name, 'rb')
  local bom = file:read(3)
  if bom == utf_8_bom then
    local fc = file:read '*a' -- be compatible
    file:close()
    file = io.open(file_name, 'wb')
    if file then
      file:write(fc)
      file:close()
    end
  else
    file:close()
  end
end

if arg then
  for i = 1, # arg do
    main(arg[i])
  end
end
