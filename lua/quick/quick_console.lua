local math_random = math.random

local utils = require 'utils'

local shuffle = utils.shuffle
local table_concat_ = utils.table_concat_


local width, height = 22, 11
local cell_pairs = 88

local is_test = true
if is_test then
    width, height = 4, 3
    cell_pairs = 3
end

local cell_type = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
}

local cell_type_count = # cell_type

local function create_board()
    local r = {}
    for i = 1, height do
        local row = {}
        table.insert(r, row)
    end
    return r
end

local function fill_board(board)
    local function generate_pos_list()
        local r = {}
        for i = 1, height do
            for j = 1, width do
                table.insert(r, { x = j, y = i })
            end
        end
        return r
    end
    local pl = shuffle(generate_pos_list())
    for i = 1, cell_pairs do
        local cell = cell_type[math_random(1, cell_type_count)]
        local pa, pb = pl[i], pl[cell_pairs + i]
        board[pa.y][pa.x] = cell
        board[pb.y][pb.x] = cell
    end
    return board
end

-- 在空闲位置点击
local function click_on_board(board, x, y)
    assert(x <= width or x >= 1 or y <= height or y >= 1)

    -- if board[y][x] ~= nil then return false end

    local cells_on_cross = {}
    local cells_found = 0
    local row = board[y]

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

    for ix = x - 1, 1, -1 do
        local c_cell = row[ix]
        if c_cell then
            cells_on_cross[c_cell] = {{ ix, y}}
            cells_found = 1
            break
        end
    end
    for ix = x + 1, width, 1 do
        if check_cell(row[ix], ix, y) then break end
    end
    for iy = y - 1, 1, -1 do
        if check_cell(board[iy][x], x, iy) then break end
    end
    for iy = y + 1, height, 1 do
        if check_cell(board[iy][x], x, iy) then break end
    end


    if cells_found >= 2 then
        local res = {}
        for k, v in pairs(cells_on_cross) do
            if # v >= 2 then
                table.insert(res, v)
            end
        end
        if # res >= 1 then
            res = table_concat_(res)
            for _, v in ipairs(res) do
                board[v[2]][v[1]] = nil
            end
            return true, res
        else
            return false
        end
    else
        return false
    end
end

--- 获取提示, 搜索board, 返回全部或第一个可以点击的有效位置
local function get_hint(board)
end

local function pos_can_click(board, x, y)
    assert(x <= width or x >= 1 or y <= height or y >= 1)
    return board[y][x] == nil
end

-- 打印出board
local function render_board(board)
    local st = {}
    for i = 1, height do
        for j = 1, width do
            table.insert(st, board[i][j] or '_')
        end
        table.insert(st, '\n')
    end
    print(table.concat(st))
end

local function test()
    --math.randomseed(os.time() * math.random(1, 4096))
    math.randomseed(1)
    local board = fill_board(create_board())
    render_board(board)
    if pos_can_click(board, 3, 3) then
        local r, l

        r, l = click_on_board(board, 2, 2)
        print(r)
        render_board(board)

        r, l = click_on_board(board, 2, 1)
        print(r)
        render_board(board)
    end
end

test()

