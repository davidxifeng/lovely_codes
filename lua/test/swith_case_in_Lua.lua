-- Lua wiki上面还有很多中不同的switch-case实现 Lua的核心特性真的很赞

--- 要求default在变参的末尾
local function switch(n, ...)
  for _,v in ipairs {...} do
    if v[1] == n or v[1] == nil then
      return v[2]()
    end
  end
end

local function case(n,f)
  return {n,f}
end

local function default(f)
  return {nil,f}
end

local action = 2

switch( action,
  case( 1, function() print("one")     end),
  case( 2, function() print("two")     end),
  case( 3, function() print("three")   end),
  default( function() print("default") end)
)

-- just for fun, this will create too much tables, do not use in real life code
