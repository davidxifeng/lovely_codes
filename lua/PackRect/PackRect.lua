
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

local bp            = require 'MaxRectsBinPack'
local minimizeBins  = bp.minimizeBins
local insertByOrder = bp.insertByOrder

local function testMinimizeBins()
    local td1 = require 'data'
    local rl = minimizeBins(840 * 4, 670, td1.d1)
    --printJson(rl)
    for _, v in ipairs(rl) do
        dumpPackResult(v)
    end
end

local function testInsertByOrder()
    local td1 = require 'data'.d1
    local r, rc, sz = insertByOrder(64, 64, td1)
    print(r and '全部pack ' or '没有全部pack')
    print('已pack列表')
    for k, v in ipairs(rc) do
        log('%d: x %d, y %d, w %d, h %d', k, v.x, v.y, v.width, v.height)
    end
    print('未pack列表')
    for k, v in ipairs(sz) do
        log('%d: w %d, h %d', k, v.width, v.height)
    end
end

local function main()
    testMinimizeBins()
    testInsertByOrder()
end

main()
