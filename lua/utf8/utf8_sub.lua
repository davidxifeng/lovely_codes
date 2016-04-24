if _VERSION ~= 'Lua 5.3' then
  return print 'require Lua 5.3'
end


--- 返回utf8字符串的子串
-- @string str 要处理的utf-8字符串, 本函数不会校验其正确性
-- @integer n 默认16
local function utf8_sub(str, n)
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
    return string.sub(s, 1, (utf8.offset(s, n + 1) or 0) - 1)
end

local function test_utf8_len()
    local s = 'ฝากไว้ ในกายเทอ' -- chars: 15

    for i = 0, 16 do
      print(utf8_sub(s, i))
      print(utf8_substr(s, i))
    end
end
test_utf8_len()
