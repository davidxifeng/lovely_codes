
EquipPos = {
    PosHelmet = 1,
    PosJacket = 2,
    PosJewel  = 3,
    PosRing   = 4,
    PosWeapon = 5,
    PosBadge  = 6,
}

td = {'hi', 'you'}

print(td[EquipPos.PosHelmet])
print(td[2])

-- Lua 5.1.5 没有公共子表达式消除的优化

function a()
    if cells[x] and cells[x][y] and cells[x][y] == CellType.Head then
        count = count + 1
    end
end

function b()
    local row = cells[x]
    local cell = row and row[y]
    if cell and cell == CellType.Head then
        count = count + 1
    end
end

local function test()
    local a, b, c = 1, 2, 3
    print(a, b, c)
    a, b, c = nil, nil, nil
    local c = print(a, b, c)
    local d = 2 > 1
    do
        local t = {}
        t[1] = 'foo'
        local a = 15 / 0
    end

    -- 标准Lua的算术/字符串运算和常量折叠优化
    local x = 1 + 2 + y -- 会常量折叠
    local y = x + 1 + 2 -- 不会常量折叠, + 是左结合的
    local z = x + 2 * 3 -- 会常量折叠, * 的优先级高
    local y = x + (2 + 3) -- 会常量折叠, ()改变了优先级

    -- 会被翻译成两条loadk指令, 加载常量到寄存器;
    local x, y = 99, 55
    -- 然会翻译成三条move指令, 交换位置, 用了一个临时变量
    x, y = y, x

    local x, y, z = 299, 255, 288
    -- 然会翻译成三条move指令, 交换位置, 用了一个临时变量
    x, y, z = y, x, z

    local s = 'abc' .. 'def' .. 'ghi'
    f()
    f(s)
    f(s, x)
    y = f(s, x)
    y, z = f(s, x)
    if y then
        return f(s, x)
    end
    y = 3
    tb:init(x)
    tb.init(tb, x)
    return f(s, x) -- Lua函数被尾调用时, return不会被执行; 被C函数调用时,才执行
    -- tailcall后面的return
end

