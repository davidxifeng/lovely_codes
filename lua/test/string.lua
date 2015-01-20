
-- Lua标准库中的字符串处理

-- find match gsub gmatch

s = '{{621,102},{96,112}}'

for xy in string.gmatch(s, '{%d+,%d+}') do
    print(xy)
    for x, y in string.gmatch(xy, '(%d+),(%d+)') do
        print(x, y)
    end
end
print(string.match(s, '{%d+,%d+}'))
