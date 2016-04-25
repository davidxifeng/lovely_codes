local M = {}

function M.table_reverse(t)
  local j = #t
  for i = 1, j / 2 do
    t[i], t[j] = t[j], t[i]
    j = j - 1
  end
  return t
end

function M.string_bytes(str)
  local i = 0
  local len = # str
  return function ()
    i = i + 1
    if i > len then
      return nil
    else
      return str:byte(i)
    end
  end
end

local function export(_ENV)
  _ENV.table_reverse = M.table_reverse
  _ENV.string_bytes = M.string_bytes
end

local function inject_stdlib()
  table.reverse = M.table_reverse
  string.bytes = M.string_bytes
end

export(_ENV)
inject_stdlib()

return M
