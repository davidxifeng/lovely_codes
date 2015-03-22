local function class()
    local cls = {ctor = function() end}
    cls.__index = cls
    function cls.new(...)
        local instance = setmetatable({}, cls)
        instance:ctor(...)
        return instance
    end
    return cls
end

CellType = { Head = 1, Tail = 2, Conductor = 3 }

local function create_world(w, h, cells)

    local function build_cells()
        local r = {}
        for _, v in ipairs(cells) do
            local row = r[v.x]
            if not row then
                row = {}
                r[v.x] = row
            end
            row[v.y] = v.type_
        end
        return r
    end

    -- init grid info
    local grid_len, gap_len = 50, 10
    local cw, ch = (grid_len + gap_len) * w, (grid_len + gap_len) * h
    local offset_x, offset_y = 400 - cw / 2, 300 - ch / 2

    return {
        width    = w,
        height   = h,
        c_width  = cw,
        c_height = ch,
        offset_x = offset_x,
        offset_y = offset_y,
        is_a     = true,
        cells_a  = build_cells(cells),
        cells_b  = build_cells(cells),
    }
end

local function draw_world(context, world)
    local function draw_cell(j, k, cell_type)
        local y, x = j * 60 - 55, k * 60 - 55
        context.strokeStyle = 'black'
        context.lineWidth = 3
        context.lineCap = 'round'
        context.lineJoin = 'round'
        context:strokeRect(x, y, 50, 50)

        local fs
        if cell_type == CellType.Conductor then
            fs = 'yellow'
        elseif cell_type == CellType.Head then
            fs = 'blue'
        elseif cell_type == CellType.Tail then
            fs = 'red'
        end

        context.fillStyle = fs
        context:fillRect(x, y, 50, 50)
    end

    context:clearRect(0, 0, world.c_width, world.c_height)

    local cells = world.is_a and world.cells_a or world.cells_b
    for j, row in pairs(cells) do
        for k, cell_type in pairs(row) do
            draw_cell(j, k, cell_type)
        end
    end
end

local function transition_world(world)
    local function check_neighbour_head(cells, j, k)
        local j_m_1 = j - 1
        local min_x = j_m_1 >= 1 and j_m_1 or 1
        local j_p_1 = j + 1
        local max_x = j_p_1 <= world.width and j_p_1 or world.width
        local k_m_1 = k - 1
        local min_y = k_m_1 >= 1 and k_m_1 or 1
        local k_p_1 = k + 1
        local max_y = k_p_1 <= world.height and k_p_1 or world.height
        local count = 0
        for x = min_x, max_x do
            for y = min_y, max_y do
                local row = cells[x]
                local cell = row and row[y]
                if cell and cell == CellType.Head then
                    count = count + 1
                end
            end
        end
        return count == 1 or count == 2
    end

    local function update_cells(next_cells, cells)
        for j, row in pairs(cells) do
            for k, cell_type in pairs(row) do
                if cell_type == CellType.Head then
                    next_cells[j][k] = CellType.Tail
                elseif cell_type == CellType.Tail then
                    next_cells[j][k] = CellType.Conductor
                elseif cell_type == CellType.Conductor then
                    if check_neighbour_head(cells, j, k) then
                        next_cells[j][k] = CellType.Head
                    else
                        next_cells[j][k] = CellType.Conductor
                    end
                end
            end
        end
    end
    if world.is_a then
        world.is_a = false
        update_cells(world.cells_b, world.cells_a)
    else
        world.is_a = true
        update_cells(world.cells_a, world.cells_b)
    end
end

-- main
do
    local demo_cells = {
        { x = 1, y = 2, type_ = CellType.Conductor},
        { x = 1, y = 3, type_ = CellType.Head},
        { x = 1, y = 4, type_ = CellType.Tail},
        { x = 2, y = 1, type_ = CellType.Conductor},
        { x = 3, y = 1, type_ = CellType.Conductor},
        { x = 4, y = 1, type_ = CellType.Conductor},
        { x = 2, y = 5, type_ = CellType.Conductor},
        { x = 3, y = 5, type_ = CellType.Conductor},
        { x = 4, y = 5, type_ = CellType.Conductor},
        { x = 5, y = 2, type_ = CellType.Conductor},
        { x = 5, y = 3, type_ = CellType.Conductor},
        { x = 5, y = 4, type_ = CellType.Conductor},
    }

    local the_world = create_world(5, 5, demo_cells)
    local context = window.document:getElementById('ww'):getContext('2d')
    context:translate(the_world.offset_x, the_world.offset_y)

    local function game_loop()
        draw_world(context, the_world)
        transition_world(the_world)
    end

    local debug = true
    local fps = debug and 5 or 60
    game_loop()
    window:setInterval(game_loop, 1000 / fps)
    --window:setTimeout(game_loop, 1000 / fps)
end
