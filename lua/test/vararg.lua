
local function basic_usage()
    -- ... and select in Lua
    function sum(...)
        local r = 0
        local n = select('#', ...)
        for i = 1, n do r = r + select(i, ...) end
        return r
    end
    function g() return 1, 2 end
    -- multi return function in Lua
    local t1 = sum(g(), 3) print(t1) -- 4
    local t2 = sum(3, g()) print(t2) -- 6
end
basic_usage()


-- map in vararg
local function sub_list(...)
    local list_start
    function list_start(start, ...)
        if start > select("#", ...) then
            return
        else
            return select(start, ...), list_start(start + 1, ...)
        end
    end
    return list_start(2, ...)
end
local function map_list(op, ...)
    if select("#", ...) == 0 then
        return
    else
        local a = ...
        return op(a), map_list(op, sub_list(...))
    end
end
local op = function (x) return x * 2 end
for _, v in ipairs({ map_list(op, unpack({ 1, 2, 3, 4, 5 })) }) do print(v) end

-- tail call
local function f() return 1, 2, 3 end
local function g(x) return x or f() end -- g会调整结果为1, h是尾调用
local function h(x) if x then return x else return f() end end
local x, y, z = g(true) print(x, y, z)
x, y, z = g(false) print(x, y, z)
x, y, z = h(true) print(x, y, z)
x, y, z = h(false) print(x, y, z)

-- difference between `return` and `return nil`

