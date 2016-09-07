#!/usr/bin/env lua

-- Wed 12:17 Sep 07
-- 专门用来解决显示unix时间戳这个痛点的

local print = print
local os_date = os.date

local opt = arg[1]


local s, fmt

local s
if opt == '-u' or opt == '--utc' then
  s = 2
  fmt = '!%c'
else
  s = 1
  fmt = '%c'
end

for i = s, # arg do
  local t = tonumber(arg[i])
  if t then print(os_date(fmt, t)) end
end

-- vim: ft=lua
