local function test()
    local d1 = os.date('*t', os.time({
        year = 2012,
        month = 12,
        day = 31,
    }))
    for k, v in pairs(d1) do
        print(k, v)
    end
end

-- 计算两天日期之间的天数差别
-- 可以正确处理闰年的情况
local function calcDaysBetween(d2, d1)
    local t2 = os.time { year = d2.year, month = d2.month, day = d2.day, }
    local t1 = os.time { year = d1.year, month = d1.month, day = d1.day, }
    return os.difftime(t2, t1) / (60 * 60 * 24)
end

local function calcDaysBetweenTest()
    local date2 = { year = 2011, month = 3, day = 1, }
    local date1 = { year = 2010, month = 12, day = 31, }
    print(calcDaysBetween(date2, date1))

    local date2 = { year = 2012, month = 3, day = 1, }
    local date1 = { year = 2011, month = 12, day = 31, }
    print(calcDaysBetween(date2, date1))
end

calcDaysBetweenTest()
