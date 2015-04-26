local math_random = math.random
local utils = require 'utils'
local shuffle = utils.shuffle
local table_concat_ = utils.table_concat_

local Board = utils.class()

function Board:ctor(cell_type, w, h, p)
    assert(type(cell_type) == 'table' and # cell_type > 0)
    self.cell_type  = cell_type
    self.width      = w or 5
    self.height     = h or 8
    self.cell_pairs = p or 10

    local data = {}
    for i = 1, self.height do table.insert(data, {}) end
    self.data = data

    local cell_type_lookup_table = {}
    for _, v in ipairs(cell_type) do
        cell_type_lookup_table[v] = true
    end
    self.cell_type_lookup_table = cell_type_lookup_table

    self:update()
    return self
end

function Board:is_cell_type(cell)
    return self.cell_type_lookup_table[cell]
end

function Board:update()
    local pl = {}
    for i = 1, self.height do
        for j = 1, self.width do
            table.insert(pl, { x = j, y = i })
        end
    end
    shuffle(pl)
    local cell_type = self.cell_type
    local cell_type_count = # cell_type
    for i = 1, self.cell_pairs do
        local cell = cell_type[math_random(1, cell_type_count)]
        local pa, pb = pl[i], pl[self.cell_pairs + i] -- FIX 相邻
        self.data[pa.y][pa.x] = cell
        self.data[pb.y][pb.x] = cell
    end
    return self
end

-- 在空闲位置点击
function Board:click_on(x, y)
    assert(x <= self.width and x >= 1 and y <= self.height and y >= 1)

    local cells_on_cross, cells_found = {}, 0

    local function check_cell(cell, ix, iy)
        if cell then
            local t = cells_on_cross[cell]
            if t then
                table.insert(t, {ix, iy})
            else
                cells_on_cross[cell] = {{ ix, iy}}
            end
            cells_found = cells_found + 1
            return true
        else
            return false
        end
    end

    local row = self.data[y]
    for ix = x - 1, 1, -1 do
        if check_cell(row[ix], ix, y) then break end
    end
    for ix = x + 1, self.width, 1 do
        if check_cell(row[ix], ix, y) then break end
    end
    for iy = y - 1, 1, -1 do
        if check_cell(self.data[iy][x], x, iy) then break end
    end
    for iy = y + 1, self.height, 1 do
        if check_cell(self.data[iy][x], x, iy) then break end
    end

    if cells_found >= 2 then
        local res = {}
        for k, v in pairs(cells_on_cross) do
            if # v >= 2 then table.insert(res, v) end
        end
        if # res >= 1 then
            res = table_concat_(res)
            for _, v in ipairs(res) do
                self.data[v[2]][v[1]] = nil
            end
            return true, res
        end
    end
    return false
end

--- 获取提示, 搜索board, 返回全部或第一个可以点击的有效位置
function Board:get_hint()
end

function Board:can_click(x, y)
    assert(x <= self.width and x >= 1 and y <= self.height and y >= 1)
    return self.data[y][x] == nil
end

function Board:render()
    local st = {}
    for i = 1, self.height do
        for j = 1, self.width do
            table.insert(st, self.data[i][j] or '_')
        end
        table.insert(st, '\n')
    end
    return table.concat(st)
end

return Board
