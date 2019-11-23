#!/usr/bin/env lua
-- install: ln -s this_file ~/bin/unixtime

-- Wed 12:17 Sep 07
-- 专门用来解决显示unix时间戳这个痛点的

local print = print
local tonumber = tonumber
local os_date = os.date

local arg = arg

local s, fmt
local opt = arg[1]
if opt == '-u' or opt == '--utc' then
  s, fmt = 2, '!%c'
elseif opt == nil or opt == '-h' or opt == '--help' then
  print [[
usage:
  unixtime [-u | --utc] unix_time_stamp
  unixtime [-h | --help]: show help info
]]
  return 0
else
  s, fmt = 1, '%c'
end

for i = s, # arg do
  local t = tonumber(arg[i])
  if t then print(os_date(fmt, t)) end
end

-- vim: ft=lua
