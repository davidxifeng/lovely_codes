
local ipairs = ipairs
local math_random = math.random


-- 简单的in place打乱算法
local function shuffle_in_place(array)
    local len = # array
    for i, v in ipairs(array) do
        local w = math_random(1, len)
        array[w], array[i] = array[i], array[w]
    end
    return array
end

local function table_concat_(array)
    local r = {}
    for _, v in ipairs(array) do
        for _, v2 in ipairs(v) do
            table.insert(r, v2)
        end
    end
    return r
end

return {
    shuffle       = shuffle_in_place,
    table_concat_ = table_concat_,
}

