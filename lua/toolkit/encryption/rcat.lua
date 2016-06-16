#!/usr/bin/env lua53

-- output file content with optional range
-- Thu 11:16 Jun 16

local filename = arg[1]
if filename then
  local f = io.open(filename, 'rb')
  if f then
    local si = arg[2] or 1
    local ei = arg[3] or -1
    io.stdout:write(f:read('a'):sub(si, ei))
    f:close()
  end
end
