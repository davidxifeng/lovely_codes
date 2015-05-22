--- 返回utf8字符串的子串
-- @string str 要处理的utf-8字符串, 本函数不会校验其正确性
-- @integer n 默认16
function limitNickLength(str, n)
    n = n or 16

    -- 不严格的utf8字符数量判断
    local function chsize(c)
        if c > 239 then return 4
        elseif c > 223 then return 3
        elseif c > 191 then return 2
        else return 1
        end
    end

    local s_len = # str

    if s_len <= n then return str end

    local s_b = string.byte
    local i = 1
    while n > 0 and i <= s_len do
        i = i + chsize(s_b(str, i))
        n = n - 1
    end
    return string.sub(str, 1, i - 1)
end

local function utf8_substr(s, n)
    -- gcc -o utf8.so -O -shared -llua lutf8lib.c
    -- compile utf8 lib from lua-5.3 with lua-5.2
    local u = require 'utf8'
    local t = string.sub(s, 1, (u.offset(s, n + 1) or 0) - 1)
    return t
end

local function test_utf8_len()
    local n
    local s = 'ฝากไว้ ในกายเทอ' -- chars: 15

    n = 14
    print(limitNickLength(s, n))
    print(utf8_substr(s, n))
    n = 15
    print(limitNickLength(s, n))
    print(utf8_substr(s, n))
    n = 16
    print(limitNickLength(s, n))
    print(utf8_substr(s, n))
end

-- e0 b8 9d ฝ
-- e0 b8 b2 า

test_utf8_len()
