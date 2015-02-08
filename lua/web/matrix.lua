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

--- 3 x 2 矩阵 处理简单的2D变换
local Matrix = class()

function Matrix:ctor(values)
    if values == nil then
        self.a, self.b, self.tx = 1, 0, 0
        self.c, self.d, self.ty = 0, 1, 0
    end
end

function Matrix:translate(tx, ty)
    local ntx = self.tx + self.a * tx + self.c * ty
    local nty = self.ty + self.b * tx + self.d * ty
    self.tx, self.ty = ntx, nty
    return self
end

-- 顺时针旋转 为负, 逆时针旋转值为正, 单位角度
function Matrix:rotate(ang)
    local rad = math.rad(ang)
    local sin = math.sin(rad)
    local cos = math.cos(rad)
    local na = self.a * cos + self.c * sin
    local nb = self.b * cos + self.d * sin
    local nc = self.c * cos - self.a * sin
    local nd = self.d * cos - self.b * sin
    self.a, self.b, self.c, self.d = na, nb, nc, nd
    return self
end

function Matrix:apply(x, y)
    local rx = self.a * x + self.c * y + self.tx
    local ry = self.b * x + self.d * y + self.ty
    return rx, ry
end


-- TODO: fix require()
_G.Matrix = Matrix

return Matrix
