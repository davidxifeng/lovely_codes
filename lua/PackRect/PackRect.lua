--- 旋转矩形 angle角度(角度) 返回旋转后的矩形的宽高
local function rotate_rect(width, height, angle)
    local hw, hh = width / 2, height / 2
    local len_tr = (hw * hw + hh * hh) ^ 0.5

    local na = math.asin(hh / len_tr) + math.rad(angle)
    local nx = math.cos(na) * len_tr
    local ny = math.sin(na) * len_tr

    local ma = math.acos(-hw / len_tr) + math.rad(angle)
    local mx = math.cos(ma) * len_tr
    local my = math.sin(ma) * len_tr

    local rx = math.max(math.abs(mx), math.abs(nx))
    local ry = math.max(math.abs(my), math.abs(ny))
    return rx * 2, ry * 2
end


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

