#!/usr/bin/env lua53
assert(_VERSION == 'Lua 5.3')

local BigNumber = require 'bignum'

local function test()
  print(BigNumber '0xFFFFFFFF')
  print(BigNumber '0xFF22334455667788')
  print(BigNumber '0x112233445566778899' * BigNumber '0xFF22334455667788')
  print(BigNumber '0x1122' * BigNumber '0xFF22334455667788')
  print(BigNumber '0x1122' * BigNumber '0x1111111111111111')
  print(BigNumber '0x1122' * BigNumber '0x0')
  print(BigNumber '0xffffffffffffffff' * BigNumber '0xffffffffffffffff')
end

test()

