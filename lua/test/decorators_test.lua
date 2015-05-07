-- Thu 10:15 Apr 16
-- Python 风格的doc 装饰器

local docstrings = setmetatable({}, {__mode = "kv"})

function document(str)
  return function(obj) docstrings[obj] = str return obj end
end

function help(obj)
  print(docstrings[obj])
end

document[[Print the documentation for a given object]](help)
document[[Add a string as documentation for an object]](document)


local f =
document[[Print a hello message]](
  function()
    print("hello")
  end
)

--f()
--help(f)

-- 另一种风格的语法
--
-- 运算符的结合性 和优先级上 只有 concat .. 合适

mt = {__concat =
  function(a,f)
    return function(...)
        print(type(a), a)
        print("decorator", table.concat(a, ","), ...)
        return f(...)
    end
  end
}

function docstring(...)
  return setmetatable({...}, mt)
end

function typecheck(...)
  return setmetatable({...}, mt)
end

local random = docstring [[Compute random number.]] .. typecheck("number", '->', "number") .. function(n) return math.random(n) end

--random(5)
random('5')
