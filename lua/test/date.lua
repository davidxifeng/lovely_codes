-- Aug 4, 21:50:22 - 22:29

local function print_date_t()
    local date_table = os.date('*t')
    for k, v in pairs(date_table) do
        print(k, v)
    end
    -- year     2015
    -- month    8
    -- day      4
    --
    -- hour     21
    -- min      50
    -- sec      22
    --
    -- yday     216
    -- wday     3
    --
    -- isdst    false
end


-- 暴力实现round
local function roundToDay(time)
    local d = os.date('*t', time)
    return os.time { year = d.year, month = d.month, day = d.day }
end

--- 计算两天日期之间的天数差别,同一天返回0
local function calcDaysDiff(t1, t2)
    return (roundToDay(t2) - roundToDay(t1)) / 86400 -- 24 * 60 * 60
end
