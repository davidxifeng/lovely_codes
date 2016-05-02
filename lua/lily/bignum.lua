local utils = require 'utils'

local BigNumber = utils.callable_class()

local function integer_to_hex(obj)
  local sign = obj.sign == '-' and '-'
  local r = {}
  for i = #obj, 1, -1 do
    table.insert(r, ('%08X'):format(obj[i]))
  end
  r = table.concat(r, ',')
  return sign and sign .. r or r
end

local function integer_to_dec(num)

  assert(math.type(num) == 'integer')
  if num == 0 then return '0' end
  local sign
  if num < 0 then
    sign = '-'
    num = - num
  end

  local r = {}

  repeat
    table.insert(r, ('%03d'):format(num % 1000))
    num = num // 1000
  until num == 0

  r = table.concat(table.reverse(r)):gsub('^0+', '')
  return sign and sign .. r or r
end

function BigNumber.__tostring(obj)
  return obj.len .. ':\t' .. integer_to_hex(obj)
end

function BigNumber.__index(_, k)
  return BigNumber[k]
end

function BigNumber.__len(obj)
  return obj.len
end

function BigNumber:copy(src)
  if self ~= src then
    self.len = src.len
    self.sign = src.sign
    table.move(src, 1, #src, 1, self)
  end
  return self
end

function BigNumber:isZero()
  return self.len == 1 and self[1] == 0
end

local function AddInteger(a, b, c)
  assert(math.type(b) == 'integer')
  c:copy(a)
  local carry = 0
  local r = b + c[1] + carry
  c[1] = r & 0xffffffff
  carry = r >> 32

  if carry == 1 then
    c[c.len + 1] = 1
    c.len = c.len + 1
  end
  return c
end

local function AddBigNumber(a, b, c)
  assert(type(b) == 'table')
  c:copy(a)
  local carry = 0

  local add_n = c.len >= b.len and b.len or c.len

  for i = 1, add_n do
    local r = b[i] + c[i] + carry
    c[i] = r & 0xffffffff
    carry = r >> 32
  end

  if carry == 1 then
    c[ c.len + 1 ] = 1
    c.len = c.len + 1
  end
  return c
end

local function Add(a, b, c)
  if type(b) == 'number' then
    return AddInteger(a, b, c)
  else
    return AddBigNumber(a, b, c)
  end
end

--- 约定a >= b
local function Sub(a, b, c)
  assert(type(c) == 'table')

  c:copy(a)

  local borrow = 0
  for i = 1, b.len do
    if c[i] > b[i] or (c[i] == b[i] and borrow == 0) then
      c[i] = c[i] - b[i] - borrow
      borrow = 0
    else
      local r = (0x1 << 32) + c[i]
      c[i] = r - b[i] - borrow
      borrow = 1
    end
  end

  if borrow == 1 then
    for i = b.len + 1, c.len do
      if c[i] >= 1 then
        c[i] = c[i] - 1
        break
      else
        c[i] = 0xFFFFFFFF
        borrow = 1
      end
    end
  end

  while c[c.len] == 0 and c.len > 1 do
    c.len = c.len - 1
  end
  return c
end

local function MulInteger(a, b, c)
  assert(type(b) == 'number')
  if a:isZero() or b == 0 then
    return c
  end
  c.len = a.len
  c.sign = a.sign == (b > 0 and '+' or '-') and '+' or '-'

  local carry = 0

  for i = 1, c.len do
    local sum = carry
    carry = 0

    local j = 1

    if i - j >= 0 and (i - j) < a.len then
      local r = a[i - j + 1]
      r = r * b
      carry = carry + (r >> 32)
      r = r & 0xffffffff
      sum = sum + r
    end

    carry = carry + (sum >> 32)
    c[i] = sum & 0xffffffff
  end

  if carry ~= 0 then
    c.len = c.len + 1
    c[c.len] = carry & 0xffffffff
  end
  return c
end

local function MulBigNumber(a, b, c)
  assert(type(b) == 'table')

  if a:isZero() or b:isZero() then
    return c
  end

  c.len = a.len + b.len - 1
  c.sign = a.sign == b.sign and '+' or '-'

  local carry = 0

  for i = 1, c.len do
    local sum = carry
    carry = 0

    for j = 1, b.len do
      local idx = i - j + 1
      if idx >= 1 and idx <= a.len then
        local r = a[idx] * b[j]
        carry = carry + (r >> 32)
        r = r & 0xffffffff
        sum = sum + r
      end
    end
    carry = carry + (sum >> 32)
    c[i] = sum & 0xffffffff
  end

  if carry ~= 0 then
    c.len = c.len + 1
    c[c.len] = carry & 0xffffffff
  end
  return c
end

local function Mul(a, b, c)
  if type(b) == 'number' then
    return MulInteger(a, b, c)
  else
    return MulBigNumber(a, b, c)
  end
end

local BYTE_ZERO = ('0'):byte(1)
local BYTE_A = ('A'):byte(1)

local function big_number(str)
  assert(type(str) == 'string')

  str = str:upper()

  local sign
  sign, str = str:match('^([%-%+]?)0[X]([%dA-F]*)$')
  if sign then
    if sign ~= '-' then
      sign = '+'
    end
    local r = BigNumber(0)
    r.sign = sign

    for c in str:bytes() do
      Mul(r, 16, r)
      Add(r, c >= BYTE_A and c - BYTE_A + 10 or c - BYTE_ZERO, r)
    end

    return r
  end
  assert(false, 'TODO')
end

function BigNumber:ctor(n)
  n = n or 0
  if type(n) == 'number' then
    self.len = 1
    self.sign = n < 0 and '-' or '+'
    self[1] = n or 0
    return self
  else
    return big_number(n)
  end
end

function BigNumber.__eq(a, b)
  if rawequal(a, b) then
    return true
  end
  if a.len == b.len and a.sign == b.sign then
    for i = 1, a.len do
      if a[i] ~= b[i] then
        return false
      end
    end
    return true
  end
  return false
end

-- + - false
-- - + true
-- + + nil
-- - - nil
local function sign_lt(m, n)
  if m ~= n then
    return m == '-'
  else
    return nil
  end
end

-- m < n : true
-- m > n : false
-- m == n : nil
local function len_lt(m, n)
  if m ~= n then
    return m < n
  else
    return nil
  end
end

-- 忽略符号，比较绝对值的大小
local function compare_without_sign(a, b)
  if a.len < b.len then
    return true
  elseif a.len > b.len then
    return false
  end

  for i = a.len, 1, -1 do
    if a[i] < b[i] then
      return true
    elseif a[i] > b[i] then
      return false
    end
  end
  return false
end

function BigNumber.__lt(a, b)
  -- 1. 比较符号
  local sr = sign_lt(a.sign, b.sign)
  if sr ~= nil then
    return sr
  end

  -- 2. 符号相同，比较位数
  sr = len_lt(a.len, b.len)
  if sr ~= nil then
    if a.sign == '+' then
      return sr
    else
      return not sr
    end
  end
  -- 3. 位数相同
  if a.sign == '+' then
    for i = a.len, 1, -1 do
      if a[i] < b[i] then
        return true
      elseif a[i] > b[i] then
        return false
      end
    end
    return false
  else
    for i = a.len, 1, -1 do
      if a[i] > b[i] then
        return true
      elseif a[i] < b[i] then
        return false
      end
    end
    return false
  end
end

function BigNumber.__le(a, b)
  return a == b or a < b
end

function BigNumber.__add(a, b)
  return Add(a, b, BigNumber(0))
end

function BigNumber.__sub(a, b)
  local r = BigNumber(0)
  if a.sign ~= b.sign then
    r.sign = a.sign
    return AddBigNumber(a, b, r)
  end
  if compare_without_sign(a, b) then
    r.sign = a.sign == '+' and '-' or '+'
    return Sub(b, a, r)
  else
    r.sign = a.sign
    return Sub(a, b, r)
  end
end

function BigNumber.__mul(a, b)
  return Mul(a, b, BigNumber(0))
end

function BigNumber.__div(a, b)
end

function BigNumber.__idiv(a, b)
end

function BigNumber.__mod(a, b)
end

function BigNumber.__pow(a, b)
end

function BigNumber.__unm(a)
end

return BigNumber
