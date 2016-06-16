#!/usr/bin/env lua53

-- Tue 17:07 Jun 14
local xxtea = require 'xxtea'

local key = 'abc'
local s = 'hello world'
local e = xxtea.encrypt(s, key)
local d = xxtea.decrypt(e, key)
print(d)
