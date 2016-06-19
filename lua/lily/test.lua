#!/usr/bin/env lua53
assert(_VERSION == 'Lua 5.3')

local BigNumber = require 'bignum'

local function test_mul()
  print(BigNumber '0x112233445566778899' * BigNumber '0xFF22334455667788')
  print(BigNumber '0x1122' * BigNumber '0xFF22334455667788')
  print(BigNumber '0x1122' * BigNumber '0x1111111111111111')
  print(BigNumber '0x1122' * BigNumber '0x0')
  print(BigNumber '0xffffffffffffffff' * BigNumber '0xffffffffffffffff')
end

local function test_sub()
  print(BigNumber '0x1122' - BigNumber '0x0')
  print(BigNumber '0x1122' - BigNumber '0x1')
  print(BigNumber '0x1122' - BigNumber '0x1121')
  print(BigNumber '0x1122' - BigNumber '0x1122')

  local b1 = BigNumber '0x100000000000000000000000000000000'
  print(b1, b1 - BigNumber '0x1ffffffff')

  print(BigNumber '0x1122' - BigNumber '-0x0')
  print(BigNumber '0x1122' - BigNumber '-0x1')
  print(BigNumber '0x1122' - BigNumber '-0x1121')
  print(BigNumber '0x1122' - BigNumber '-0x1122')

  b1 = BigNumber '-0x100000000000000000000000000000000'
  print(b1, b1 - BigNumber '0x1ffffffff')

  print(BigNumber '-0x1122' - BigNumber '-0x1121', -0x1122 - -0x1121)
  print(BigNumber '-0x1122' - BigNumber '-0x1122', -0x1122 - -0x1122)
  print(BigNumber '0x1122' - BigNumber '0x1122', 0x1122 - 0x1122)
end

local function test_lt()
  assert(BigNumber '0x0' < BigNumber '0x0' == false)
  assert(BigNumber '0x1' < BigNumber '0x1' == false)
  assert(BigNumber '0x1' < BigNumber '0x2' == true)
  assert(BigNumber '0x2' < BigNumber '0x1' == false)

  assert(BigNumber '-0x1' < BigNumber '-0x1' == false)
  assert(BigNumber '-0x1' < BigNumber '-0x2' == false)
  assert(BigNumber '-0x2' < BigNumber '-0x1' == true)

  assert(BigNumber '-0x100000000000000000000000000000000' < BigNumber '-0x100000000000000000000000000000000' == false)
  assert(BigNumber '-0x1' < BigNumber '0x2' == true)
  assert(BigNumber '0x2' < BigNumber '-0x1' == false)
  assert(BigNumber '-0x200000000000000000000000000000000' < BigNumber '-0x100000000000000000000000000000000' == true)
  assert(BigNumber '-0x200000000000000000000000000000000' < BigNumber '-0x100000' == true)
  assert(BigNumber '-0x100000000000000000000000000000001' < BigNumber '-0x100000000000000000000000000000000' == true)

  assert(BigNumber '0x100000000000000000000000000000001' < BigNumber '0x100000000000000000000000000000000' == false)
end

local function test_le()
  assert(BigNumber '0x0' <= BigNumber '0x0' == true)
  assert(BigNumber '0x1' <= BigNumber '0x1' == true)
  assert(BigNumber '0x1' <= BigNumber '0x2' == true)
  assert(BigNumber '0x2' <= BigNumber '0x1' == false)

  assert(BigNumber '-0x1' <= BigNumber '-0x1' == true)
  assert(BigNumber '-0x1' <= BigNumber '-0x2' == false)
  assert(BigNumber '-0x2' <= BigNumber '-0x1' == true)

  assert(BigNumber '-0x100000000000000000000000000000000' <= BigNumber '-0x100000000000000000000000000000000' == true)
  assert(BigNumber '-0x1' <= BigNumber '0x2' == true)
  assert(BigNumber '0x2' <= BigNumber '-0x1' == false)
  assert(BigNumber '-0x200000000000000000000000000000000' <= BigNumber '-0x100000000000000000000000000000000' == true)
  assert(BigNumber '-0x200000000000000000000000000000000' <= BigNumber '-0x100000' == true)
  assert(BigNumber '-0x100000000000000000000000000000001' <= BigNumber '-0x100000000000000000000000000000000' == true)

  assert(BigNumber '0x100000000000000000000000000000001' <= BigNumber '0x100000000000000000000000000000000' == false)

  assert(BigNumber '0x100000000000000000000000000000001' <= BigNumber '0x100000000000000000000000000000001' == true)

  assert(BigNumber '0x100000000000000000000000000000001' <= BigNumber '0x100000000020000000000000000000001' == true)
  assert(BigNumber '0x100000000000000000000000000000001' <= BigNumber '0x100000000000000000000020000000001' == true)
end

test_mul()
test_sub()
test_lt()
test_le()
