
function f(x)
    print('hello ', x)
end

function loader()
    local codes = {
        'print "hi load()"\n',
        'f "loader"\n'
    }
    local i = 1
    return function()
        local r = codes[i]
        i = i + 1
        return r
    end
end

function test_load()
    local lf, e = load(loader(), 'test_load')
    if lf ~= nil then
        lf()
    else
        print('load 失败: ', e)
    end
end
test_load()

-- loadstring
assert(loadstring('print "loadstring"', 'test.lua'))()

