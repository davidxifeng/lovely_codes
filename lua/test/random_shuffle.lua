--- 简单的in place 打乱算法
local function shuffle_in_place(array)
    local len = # array
    for i, v in ipairs(array) do
        local w = math.random(1, len)
        array[w], array[i] = array[i], array[w]
    end
end

function test_shuffle()
    math.randomseed(os.time() * math.random(1, 4096))
    local a = {1,2,3,4,5}
    shuffle_in_place(a)
    local r = {}
    for _, v in ipairs(a) do
        table.insert(r, v)
    end
    print(table.concat(r, ', '))
end


for i = 1, 10 do
    test_shuffle()
end
