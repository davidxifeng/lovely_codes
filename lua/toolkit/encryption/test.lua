#!/usr/bin/env lua53

local zlib = require 'zlib'
local function compress(s)
  return zlib.deflate()(s, 'full')
end
local function decompress(s)
  return zlib.inflate()(s)
end

-- Tue 17:07 Jun 14
local xxtea = require 'xxtea'
local key = 'xxtea key'
print(xxtea.decrypt(xxtea.encrypt('hello world', key), key))

local blowfish = require 'blowfish'

local function dump_string(s)
  return (s:gsub('(.)', function (c)
    return ('%X '):format(c:byte())
  end))
end

local function hex_to_str(s)
  return s:gsub('%X', ''):gsub('(..)', function (bs)
    return string.char(tonumber('0x' .. bs))
  end)
end

local s = hex_to_str('hello blowfish key')
print(#s, dump_string(s))
local blowfish_key = blowfish.new(s)

local fc = '123'
local ec, rl = blowfish_key:encrypt(fc)
print(#ec, rl)
--blowfish_key:reset()
local dc = blowfish_key:decrypt(ec)
print(#dc, dc:sub(1, rl))
