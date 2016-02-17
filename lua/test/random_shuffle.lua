--- 简单的in place 打乱算法
local function shuffle_in_place(array)
    local len = # array
    for i, v in ipairs(array) do
        local w = math.random(1, len)
        array[w], array[i] = array[i], array[w]
    end
    return array
end

local function test_shuffle()
    math.randomseed(os.time() * math.random(1, 4096))
    local a = {1,2,3,4,5}
    shuffle_in_place(a)
    local r = {}
    for _, v in ipairs(a) do
        table.insert(r, v)
    end
    print(table.concat(r, ', '))
end

-- 从list中返回n个元素
local function get_random_sublist(array, n)
    assert(n <= #array)
    local r = {}
    local t = {}
    local len = # array
    for i = 1, n do
        while true do
            local ri = math.random(len)
            if not t[ri] then
                t[ri] = true
                table.insert(r, array[ri])
                break
            end
        end
    end
    return r
end

local function test_rs()
    local array = {1,2,3,4,5}
    local r = {}
    for _, v in ipairs(get_random_sublist(array, 3)) do
        table.insert(r, v)
    end
    print(table.concat(r, ', '))
end


local function main()
    --for i = 1, 10 do test_shuffle() end
    for i = 1, 10 do test_rs()end
end

main()
