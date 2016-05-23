

local f, t = function() return function() end end, {
  nil,
  [false]  = 'Lua 5.1',
  [true]   = 'Lua 5.2',
  [1/'-0'] = 'Lua 5.3',
  [1]      = 'LuaJIT'
}

local version = t[1] or t[1/0] or t[f()==f()]
print(version)
