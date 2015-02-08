local function drawRect(ctx, rcs)
    ctx:beginPath()
    ctx:moveTo(rcs[1].x, rcs[1].y)
    ctx:lineTo(rcs[2].x, rcs[2].y)
    ctx:lineTo(rcs[3].x, rcs[3].y)
    ctx:lineTo(rcs[4].x, rcs[4].y)
    ctx:lineTo(rcs[1].x, rcs[1].y)
    --[[
    ctx:lineTo(rcs[3].x, rcs[3].y)
    ctx:moveTo(rcs[4].x, rcs[4].y)
    ctx:lineTo(rcs[2].x, rcs[2].y)
    --]]
    ctx:stroke()
end


local context = window.document:getElementById('cc'):getContext('2d')

local function go(t, m)
    local r = {}
    for _, v in ipairs(t) do
        local x, y = m:apply(v.x, v.y)
        table.insert(r, { x = x, y = y })
    end
    return r
end

local function main()
    context:save()

    -- context init
    context:translate(400, 300)
    context:scale(0.39, -0.39)

    local tb = {
        { x = 0, y = 0}, { x = 400, y = 0},
        { x = 400, y = 600}, { x = 0, y = 600},
    }
    context.strokeStyle = 'rgba(255, 32, 128, 128)'
    drawRect(context, tb)

    local m = Matrix.new()
    m:translate(100, 120)
    context.strokeStyle = 'rgba(15, 232, 128, 128)'
    drawRect(context, go(tb, m))

    m = Matrix.new()
    m:translate(100, 120):rotate(-55)
    context.strokeStyle = 'blue'
    drawRect(context, go(tb, m))

    m = Matrix.new()
    m:translate(100, 120):rotate(-55):translate(-100, -120)
    context.strokeStyle = 'yellow'
    local ntb = go(tb, m)
    drawRect(context, ntb)

    m = Matrix.new()
    m:translate(100, 120):rotate(55):translate(-101, -121)
    context.strokeStyle = 'black'
    drawRect(context, go(ntb, m))

    context:restore()
end

main()
