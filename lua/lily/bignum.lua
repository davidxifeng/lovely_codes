require 'utils'

local BigNumber = {}

local function integer_to_hex(obj)
  local sign = obj.sign == '-' and '-'
  local r = {}
  for i = #obj, 1, -1 do
    table.insert(r, ('%08X'):format(obj[i]))
  end
  r = table.concat(r)
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

  r = table.concat(table_reverse(r)):gsub('^0+', '')
  return sign and sign .. r or r
end

function BigNumber.__tostring(obj)
  return integer_to_hex(obj)
end

function BigNumber.__index(_, k)
  if type(k) == 'number' then
    return 0
  else
    return BigNumber[k]
  end
end

function BigNumber.__len(obj)
  return obj.len
end

function BigNumber:copy(src)
  if self ~= src then
    self.len = src.len
    self.sign = src.sign
    table.move(self, 1, #src, 1, self)
  end
  return self
end

function BigNumber:isZero()
  return self.len == 1 and self[1] == 0
end

function BigNumber:init(n)
  self.len = 1
  self.sign = n < 0 and '-' or '+'
  self[1] = n or 0
  return self
end

local function Add(a, b, c)
  c:copy(a)
  if type(b) == 'number' then
    local carry = 0
    local r = b + c[1] + carry
    c[1] = r & 0xffffffff
    carry = r >> 32

    if carry == 1 then
      c[c.len + 1] = 1
      c.len = c.len + 1
    end
  elseif type(b) == 'table' then
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
  end
  return c
end

local function Mul(a, b, c)

  if type(b) == 'number' then
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
  elseif type(b) == 'table' then
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
  end
  return c
end

function BigNumber.__add(a, b)
  return Add(a, b, BigNumber(0))
end

function BigNumber.__sub(a, b)
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

return setmetatable(BigNumber, {
  __call = function (class, n)
    n = n or 0
    local tp = type(n)
    if tp == 'number' then
      return setmetatable({}, class):init(n)
    elseif tp == 'string' then
      return big_number(n)
    end
  end
})
