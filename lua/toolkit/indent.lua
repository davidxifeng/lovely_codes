#!/usr/bin/env lua53
-- Thu 15:17 Apr 14

-- 修改indent
-- 删除第一个非空格字符前一半数量的空格
-- 或增加一倍数量的空格
--
-- 使用方法:
-- indent [--add-indent] 文件[...]

if #arg  > 0 then

  local add_indent = false

  for i, file in ipairs(arg) do
    local r = {}

    if file == '--add-indent' then
      add_indent = true
      goto continue
    end

    for line in io.lines(file) do
      if add_indent then
        local c = line:match('^ +()')
        if c then
          table.insert(r, (' '):rep(c - 1) .. line)
        else
          table.insert(r, line)
        end
      else
        local c = line:match('^ +()') or 1
        table.insert(r, line:sub((c - 1) // 2 + 1))
      end
    end

    local f = io.open(file, 'w')
    f:write(table.concat(r, '\n'), '\n')
    f:close()

    ::continue::
  end
else

  print [[
usage:
  ./indent.lua [--add-indent] file, ...
]]

end
