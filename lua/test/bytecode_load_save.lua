#!/usr/bin/env lua5.1

-- load and save tricks

local function test_lua_51()
    -- corsix (Peter Cawley)写了关于利用此漏洞的方法
    -- https://gist.github.com/corsix/6575486
    local asnum = loadstring(
        (string.dump(function(x)
    for i = x, x, 0 do
        return i
    end end):gsub("\96%z%z\128", "\22\0\0\128")))

    do local dummy = 2^52 end
    local f = function() end
    print(tostring(f))     --> function: 0x7fc543c0be70
    print(asnum(f) - 2^52) --> -4.5035996273705e+15
end


test_lua_51()

local function test_a()
    local df = function()end
    local db = string.dump(df)

    local r = {}
    for i = 1, # db do
        table.insert(r, string.format('%02X ', db:byte(i)))
    end
    print(table.concat(r))
end
test_a()
print(_VERSION)
