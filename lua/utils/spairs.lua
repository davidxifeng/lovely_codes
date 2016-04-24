#!/usr/bin/env lua53
-- Mon 09:19 Mar 21

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

local function spairs(t, cmp)
    local sort_keys = {}
    for k, v in pairs(t) do
        table.insert(sort_keys, {k, v})
    end
    local sf
    if cmp then
        sf = function (a, b) return cmp(a[1], b[1]) end
    else
        sf = function (a, b) return a[1] < b[1] end
    end
    table.sort(sort_keys, sf)

    return function (tb, index)
        local ni, v = next(tb, index)
        if ni then
            return ni, v[1], v[2]
        else
            return ni
        end
    end, sort_keys, nil
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
