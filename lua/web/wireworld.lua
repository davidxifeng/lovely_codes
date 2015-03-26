local is_debug = true

local grid_len = 4
local gap_len = 2

local CellType_Head = 'blue'
local CellType_Tail = 'red'
local CellType_Conductor = 'yellow'

local function get_cells_from_image(image_url, on_load)
    local img = window.document:createElement('img')
    img.src = image_url
    img.onload = function ()
        local canvas = window.document:createElement('canvas')
        canvas.width = img.width
        canvas.height = img.height
        if is_debug then
            window.document.body:appendChild(canvas)
        end

        local context = canvas:getContext('2d')
        context:drawImage(img, 0, 0)

        local imgData = context:getImageData(0, 0, img.width, img.height)
        local iw, ih = imgData.width, imgData.height
        local data = imgData.data
        local cells = {}
        for y = 0, ih - 1 do
            for x = 0, iw - 1 do
                local b = y * iw * 4 + x * 4
                local r, g, b = data[b], data[b + 1], data[b + 2]

                local cell_type
                if r >= 128 and g >= 128 and b < 128 then
                    cell_type = CellType_Conductor
                elseif r >= 128 and g < 128 and b < 128 then
                    cell_type = CellType_Tail
                elseif r < 128 and g < 128 and b >= 128 then
                    cell_type = CellType_Head
                end

                if cell_type then
                    table.insert(cells, {
                        x = x + 1, y = y + 1, type_ = cell_type
                    })
                end
            end
        end
        if on_load then
            on_load(iw, ih, cells)
        end
    end
end

local function create_world(image_url, world_loader)

    local function build_cells(cells)
        local r = {}
        for _, v in ipairs(cells) do
            local row = r[v.y]
            if not row then
                row = {}
                r[v.y] = row
            end
            row[v.x] = v.type_
        end
        return r
    end

    get_cells_from_image(image_url, function (w, h, cells)

        -- init grid info
        local cw, ch = (grid_len + gap_len) * w, (grid_len + gap_len) * h
        local offset_x, offset_y = 400 - cw / 2, 300 - ch / 2

        world_loader {
            width    = w,
            height   = h,
            c_width  = cw,
            c_height = ch,
            offset_x = offset_x,
            offset_y = offset_y,
            is_a     = true,
            cells_a  = build_cells(cells),
            cells_b  = build_cells(cells),
            gens     = 0,
        }
    end)
end

local function draw_world(context, world)
    -- 迭代次数
    local rc = function() return -30, -80, 55, 20 end
    context:clearRect(rc())
    if is_debug then
        context.fillStyle = 'gray'
        context:fillRect(rc())
    end
    context.fillStyle = 'red'
    context:fillText(world.gens, -20, -65)

    local function draw_cell(j, k, cell_type)
        local cell_border = 0.5

        local x = k * (grid_len + gap_len) - grid_len - gap_len / 2
        local y = j * (grid_len + gap_len) - grid_len - gap_len / 2

        -- draw cell border
        context.strokeStyle = 'black'
        context.lineWidth = cell_border
        context.lineCap = 'round'
        context.lineJoin = 'round'
        context:strokeRect(x, y, grid_len, grid_len)

        -- draw cell rect
        context.fillStyle = cell_type
        context:fillRect(x, y, grid_len, grid_len)
    end

    -- cells
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
        local max_y = j < world.height and j + 1 or world.height
        local max_x = k < world.width and k + 1 or world.width
        local count = 0
        for y = j > 1 and j - 1 or 1, max_y do
            for x = k > 1 and k - 1 or 1, max_x do
                local row = cells[y]
                local cell = row and row[x]
                if cell and cell == CellType_Head then
                    if count == 2 then return false end
                    count = count + 1
                end
            end
        end
        return count == 1 or count == 2
    end

    local function update_cells(next_cells, cells)
        for j, row in pairs(cells) do
            for k, cell_type in pairs(row) do
                if cell_type == CellType_Head then
                    next_cells[j][k] = CellType_Tail
                elseif cell_type == CellType_Tail then
                    next_cells[j][k] = CellType_Conductor
                elseif cell_type == CellType_Conductor then
                    if check_neighbour_head(cells, j, k) then
                        next_cells[j][k] = CellType_Head
                    else
                        next_cells[j][k] = CellType_Conductor
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
    world.gens = world.gens + 1
end

-- main
local image_url = 'image/circuit.bmp'
create_world(image_url, function (the_world)
    local context = window.document:getElementById('ww'):getContext('2d')
    context:translate(the_world.offset_x, the_world.offset_y)

    local function game_loop()
        draw_world(context, the_world)
        transition_world(the_world)
    end

    --local fps = is_debug and 2 or 60
    local fps = 60
    game_loop()
    window:setInterval(game_loop, 1000 / fps)
    --window:setTimeout(game_loop, 1000 / fps)
end)
