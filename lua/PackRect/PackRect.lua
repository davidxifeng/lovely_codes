
local function log(...)
    print(string.format(...))
end

local function printJson(obj)
    local json = require 'json'
    local r = json.encode(obj)
    print(r)
end

local function dumpPackResult(dst)
    for k, v in ipairs(dst) do
        log('%d: x = %d, y = %d, width = %d, height = %d, isRotate = %s'
            , k, v.x, v.y, v.width, v.height, tostring(v.isRotate))
    end
end

local bp = require 'MaxRectsBinPack'
local minimizeBins = bp.minimizeBins
local createBin = bp.createBin
local insert = bp.insert

local function testMaxRectBL()
    local td1 = require 'data'
    local rl = minimizeBins(840 * 4, 670, td1.d1)
    --printJson(rl)
    for _, v in ipairs(rl) do
        dumpPackResult(v)
    end
end

testMaxRectBL()

