
-- Lua标准库中的字符串处理

local function string_pattern_test()
    -- find match gsub gmatch
    local s = '{{621,102},{96,112}}'

    for xy in string.gmatch(s, '{%d+,%d+}') do
        print(xy)
        for x, y in string.gmatch(xy, '(%d+),(%d+)') do
            print(x, y)
        end
    end
    print(string.match(s, '{%d+,%d+}'))

    local x, y = s:match('{%d+,%d+}'):match('(%d+),(%d+)')
    print('x, y: ', x, y)
end

-- '([^\n]*)[\n]?'
-- ?    0 or 1
-- *    0 or more repetitions of characters 最长匹配
-- -    0 or more, 最短匹配
-- +    1 or more repetitions of characters in the class, 最长匹配

--- split string by newline
local function string_split(str)
    local t = {}
    for line in string.gmatch(str, '([^\n]+)') do
        table.insert(t, line)
    end
    return t
end

local function test_split()
    local s = 'hello\nworld\n\ngo'
    local r = string_split(s)
    print('split result count is: ', #r)
    for _, v in ipairs(r) do
        print(v)
    end
end

--string_pattern_test()
test_split()
