--- 2015 June 24 测试Lua 单个字符串或表参数,可以省略括号的特性

local function rf(s)
    if s == 'add' then
        return function(a)
            return 1 + a
        end
    elseif s == 'sub' then
        return function(a)
            return 1 - a
        end
    end
end

print(rf 'add' '2') -- this is okay

