#!/usr/bin/env lua53

local function hashsize(table)
    local n = 0
    for k, v in pairs(table) do
        n = n + 1
    end
    return n
end

local function elem(list, e)
    for _, v in ipairs(list) do
        if v == e then
            return true
        end
    end
    return false
end

local function gen_snext(t, cmp)
    local sort_keys = {}
    for k, _ in pairs(t) do
        table.insert(sort_keys, k)
    end
    table.sort(sort_keys, cmp)

    return function (t, index)
        if index == nil then
            local rk = sort_keys[1]
            return 1, rk, t[rk]
        else
            index = index + 1
            if index > #sort_keys then
                return nil
            else
                local rk = sort_keys[index]
                return index, rk, t[rk]
            end
        end
    end
end

-- 接受一个排序key的函数
local function spairs(t, cmp)
    return gen_snext(t, cmp), t, nil
end

local t = {
    hello = 1,
    world = 2,
    test = 3,
    abc = 4,
}

for i, k, v in spairs(t) do
    print(i, k, v)
end
