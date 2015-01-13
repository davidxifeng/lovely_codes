local tb = {
    x = 1,
    y = 2,
    z = 3,
}

-- A:
do
    local the_next, t, var_nil = pairs(tb)
    while true do
        local k, v = the_next(t, var_nil)
        var_nil = k
        if var_nil == nil then break end
        print(k, ',', v)
    end
end

--[[
ipairs(t) : Returns three values: an iterator function, the table t, and 0
ipairs :(1, t[1]), (2, t[2]) ...
]]

