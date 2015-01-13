
-- ... and select in Lua
function f(...)
    local n = select('#', ...)
    local sum = 0
    for i = 1, n do
        sum = sum + select(i, ...)
    end
    return sum
end

function g()
    return 1, 2
end

-- multi return function in Lua
local t1 = f(g(), 3)
print(t1) -- 4
local t2 = f(3, g())
print(t2) -- 6
