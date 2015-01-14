
local function log(...)
    print(string.format(...))
end

local function printJson(obj)
    print(require 'json'.encode(obj))
end

local function dumpPackResult(dst)
    for k, v in ipairs(dst) do
        log('%d: x = %d, y = %d, width = %d, height = %d, isRotate = %s',
            k, v.x, v.y, v.width, v.height, tostring(v.isRotate))
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

local function testInsert()
    local td1 = require 'data'.d1
    local bin = createBin(1024, 1024)
    for k, v in ipairs(td1) do
        local r = insert(bin, v.width, v.height, k)
        if not r then
            log('pack size %d (w: %d, h: %d) failed', k, v.width. v.height)
        end
    end
    for k, v in ipairs(bin.usedRectangles) do
        log('%d: x: %d, y: %d, w: %d, h: %d', v.id, v.x, v.y, v.width, v.height)
    end
end

local function main()
    testMaxRectBL()
    testInsert()
end

main()
