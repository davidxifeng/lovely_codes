-- MaxRectsBinPack module

local export = {
    createBin, insert, insertList, minimizeBins, rotate_rect, layoutRect
}

local createBin, insert, insertList, minimizeBins, rotate_rect, layoutRect

local scoreRect, splitFreeNode, placeRect, pruneFreeList, findPosition

local copyRect, copyNode

-- import
local ipairs       = ipairs
local pairs        = pairs
local table_insert = table.insert
local table_remove = table.remove
local table_sort   = table.sort
local math_huge    = math.huge
local math_sin     = math.sin
local math_cos     = math.cos
local math_asin    = math.asin
local math_acos    = math.acos
local math_rad     = math.rad
local math_abs     = math.abs
local math_max     = math.max

-- pack 过程中是否旋转rect
local ROTATE_WHEN_PLACE_RECT = false

--- createBin
-- @number w bin width
-- @number h bin height
function createBin(w, h)
    return {
        binWidth       = w,
        binHeight      = h,
        freeRectangles = { {x = 0, y = 0, width = w, height = h} },
        usedRectangles = {},
    }
end

--- insert a single size to bin
-- @return result or nil
function insert(bin, width, height, id)
    local newNode = findPosition(bin, width, height, score1, score2)
    if newNode.height == 0 then
        return nil
    end
    newNode.id = id
    placeRect(bin, newNode)
    return copyNode(newNode)
end

--- insert size list
-- @param sizeList input size array, {id, width, height}
-- @return is pack all and result list
function insertList(bin, sizeList)
    local rectList = {}

    while # sizeList > 0 do
        local bestScore1 = math_huge
        local bestScore2 = math_huge
        local bestRectIndex = -1
        local bestNode

        for k, v in ipairs(sizeList) do
            local newNode, score1, score2 = scoreRect(bin, v.width, v.height)
            if score1 < bestScore1
                or (score1 == bestScore1 and score2 < bestScore2) then
                bestScore1 = score1
                bestScore2 = score2
                bestNode = newNode
                bestRectIndex = k
            end
        end

        if bestRectIndex == -1 then
            return false, rectList
        end

        bestNode.id = sizeList[bestRectIndex].id
        table_insert(rectList, copyNode(bestNode))

        placeRect(bin, bestNode)
        table_remove(sizeList, bestRectIndex)
    end
    return true, rectList
end

--- 放置rect,计算评分
-- @return 新结点 得分x y
function scoreRect(bin, w, h)
    local score1, score2 = math_huge, math_huge
    local newNode
    newNode, score1, score2 = findPosition(bin, w, h, score1, score2)
    if newNode.height == 0 then
        score1, score2 = math_huge, math_huge
    end
    return newNode, score1, score2
end

--- 在bottom left开始寻找位置
function findPosition(bin, width, height, bestY, bestX)
    local bestNode = { x = 0, y = 0, width = 0, height = 0 }
    bestY = math_huge
    for _, v in ipairs(bin.freeRectangles) do
        -- Try to place the rectangle in upright (non-flipped) orientation.
        if v.width >= width and v.height >= height then
            local topSideY = v.y + height
            if topSideY < bestY or (topSideY == bestY and v.x < bestX) then
                bestNode.x      = v.x
                bestNode.y      = v.y
                bestNode.width  = width
                bestNode.height = height

                bestNode.isRotate = false

                bestY           = topSideY
                bestX           = v.x
            end
        end
        if ROTATE_WHEN_PLACE_RECT then
            if v.width >= height and v.height >= width then
                local topSideY = v.y + width
                if topSideY < bestY or (topSideY == bestY and v.x < bestX) then
                    bestNode.x      = v.x
                    bestNode.y      = v.y
                    bestNode.width  = height
                    bestNode.height = width

                    bestNode.isRotate = true

                    bestY           = topSideY
                    bestX           = v.x
                end
            end
        end
    end
    return bestNode, bestY, bestX
end

function copyRect(rect)
    return { x = rect.x, y = rect.y, width = rect.width, height = rect.height }
end

function copyNode(node)
    local newNode    = copyRect(node)
    newNode.isRotate = node.isRotate
    newNode.id       = node.id
    return newNode
end

function placeRect(bin, node)
    local i = 1
    while i <= # bin.freeRectangles do
        if splitFreeNode(bin, bin.freeRectangles[i], node) then
            table_remove(bin.freeRectangles, i)
            i = i - 1
        end
        i = i + 1
    end
    pruneFreeList(bin)
    table_insert(bin.usedRectangles, node)
end

function splitFreeNode(bin, freeNode, usedNode)
    -- Test with SAT if the rectangles even intersect.
    if usedNode.x >= freeNode.x + freeNode.width
        or usedNode.x + usedNode.width <= freeNode.x
        or usedNode.y >= freeNode.y + freeNode.height
        or usedNode.y + usedNode.height <= freeNode.y then
        return false
    end

    if usedNode.x < freeNode.x + freeNode.width
        and usedNode.x + usedNode.width > freeNode.x then
        -- New node at the top side of the used node.
        if usedNode.y > freeNode.y
            and usedNode.y < freeNode.y + freeNode.height then
            local newNode = copyRect(freeNode)
            newNode.height = usedNode.y - newNode.y
            table_insert(bin.freeRectangles, newNode)
        end

        -- New node at the bottom side of the used node.
        if usedNode.y + usedNode.height < freeNode.y + freeNode.height then
            local newNode = copyRect(freeNode)
            newNode.y = usedNode.y + usedNode.height
            newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height)
            table_insert(bin.freeRectangles, newNode)
        end
    end

    if usedNode.y < freeNode.y + freeNode.height
        and usedNode.y + usedNode.height > freeNode.y then
        -- New node at the left side of the used node
        if usedNode.x > freeNode.x
            and usedNode.x < freeNode.x + freeNode.width then
            local newNode = copyRect(freeNode)
            newNode.width = usedNode.x - newNode.x
            table_insert(bin.freeRectangles, newNode)
        end

        -- New node at the right side of the used node.
        if usedNode.x + usedNode.width < freeNode.x + freeNode.width then
            local newNode = copyRect(freeNode)
            newNode.x = usedNode.x + usedNode.width
            newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width)
            table_insert(bin.freeRectangles, newNode)
        end
    end
    return true
end

--- rect utility
-- @return boolean
local function isContainedIn(a, b)
    return a.x >= b.x and a.y >= b.y
            and a.x + a.width <= b.x + b.width
            and a.y + a.height <= b.y + b.height
end

function pruneFreeList(bin)
    -- Go through each pair and remove any rectangle that is redundant.
    local freeRectangles = bin.freeRectangles
    local i = 1
    while i < # freeRectangles do
        local j = i + 1
        while j <= # freeRectangles do
            if isContainedIn(freeRectangles[i], freeRectangles[j]) then
                table_remove(freeRectangles, i)
                i = i - 1
                break
            end
            if isContainedIn(freeRectangles[j], freeRectangles[i]) then
                table_remove(freeRectangles, j)
                j = j - 1
            end
            j = j + 1
        end
        i = i + 1
    end
end

local function copyList(list)
    local r = {}
    for i, v in ipairs(list) do
        local nv = { id = i, width = v.width, height = v.height }
        table_insert(r, nv)
    end
    return r
end

--- minimizeBins
-- @number maxBinWidth 目标bin宽度
-- @number maxBinHeight 目标bin高度
-- @array inputSizeList rect 列表
-- @return Bin 列表
function minimizeBins(maxBinWidth, maxBinHeight, inputSizeList)
    local sizeList = copyList(inputSizeList)
    local binList = {}
    repeat
        local bin = createBin(maxBinWidth, maxBinHeight)
        local ok, r = insertList(bin, sizeList)
        table_sort(r, function(a, b) return a.id < b.id end)
        table_insert(binList, r)
    until ok
    return binList
end

--- 旋转矩形 angle角度(角度) 返回旋转后的矩形的宽高
function rotate_rect(width, height, angle)
    local hw, hh = width / 2, height / 2
    local len_tr = (hw * hw + hh * hh) ^ 0.5

    local na = math_asin(hh / len_tr) + math_rad(angle)
    local nx = math_cos(na) * len_tr
    local ny = math_sin(na) * len_tr

    local ma = math_acos(-hw / len_tr) + math_rad(angle)
    local mx = math_cos(ma) * len_tr
    local my = math_sin(ma) * len_tr

    local rx = math_max(math_abs(mx), math_abs(nx))
    local ry = math_max(math_abs(my), math_abs(ny))
    return rx * 2, ry * 2
end

function layoutRect()
end


export.createBin    = createBin
export.insert       = insert
export.insertList   = insertList
export.minimizeBins = minimizeBins
export.rotate_rect  = rotate_rect
export.layoutRect   = layoutRect

return export
