
a = {
    [3]=3,
    one = 1,
    ['two'] = 2,
    [{test = 'hello lua'}] = 8,
    [{c = 'lua'}] = 6,
    four = 4,
    five = 5,
    seven = 7,
    love = nil,
}
--print(a[3], a.one, a.two)

b = {}
for k, v in pairs(a) do
    print(k, v)
    b[v] = k
end

print ('len of b is '.. #b)

-- 从1开始,一直到2,3...序列中第一个不存在的integer key
for i, v in ipairs(b) do
    print(i, v)
end

