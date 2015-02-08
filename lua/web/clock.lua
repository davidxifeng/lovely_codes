local function rot(x, y, ang)
    local r = math.rad(ang and ang or -55)
    local rx = x * math.cos(r) + y * math.sin(r)
    local ry = y * math.cos(r) - x * math.sin(r)
    return rx, ry
end

local function drawRect(ctx, rcs)
    ctx:beginPath()
    ctx:moveTo(rcs[1].x, rcs[1].y)
    ctx:lineTo(rcs[2].x, rcs[2].y)
    ctx:lineTo(rcs[3].x, rcs[3].y)
    ctx:lineTo(rcs[4].x, rcs[4].y)
    ctx:lineTo(rcs[1].x, rcs[1].y)
    ctx:lineTo(rcs[3].x, rcs[3].y)
    ctx:moveTo(rcs[4].x, rcs[4].y)
    ctx:lineTo(rcs[2].x, rcs[2].y)
    ctx:stroke()
end

local context = window.document:getElementById('cc'):getContext('2d')

local function main()
    context:save()
    context:translate(400, 300)
    context:scale(0.45, 0.45)
    context.strokeStyle = 'rgba(255, 32, 128, 128)'

    local tb = {
        { x = -370, y = 560}, { x = 370, y = 560},
        { x = 370, y = -560}, { x = -370, y = -560},
    }
    drawRect(context, tb)
    local function f(t, ag)
        local r = {}
        for _, v in ipairs(t) do
            local x, y = rot(v.x, v.y, ag)
            table.insert(r, { x = x, y = y })
        end
        return r
    end
    context.strokeStyle = 'rgba(15, 232, 128, 128)'

    --[[
    drawRect(context, {
        { x = -5, y = 5}, { x = 5, y = 5},
        { x = 5, y = -5}, { x = -5, y = -5},
    })
    --]]

    local r = -55
    drawRect(context, f(tb, r))
    drawRect(context, f(tb, -r))
    context:restore()
end
main()
