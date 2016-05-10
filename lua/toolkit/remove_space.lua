-- Thu 15:17 Apr 14

-- 删除每行 第一个非空格字符前一半数量的空格
--
-- 使用方法:
-- remove_space 文件[...]

for i, file in ipairs(arg) do

  local r = {}

  for line in io.lines(file) do
    local c = line:match('^ +()') or 1
    table.insert(r, line:sub((c - 1)//2 + 1))
  end

  local f = io.open(file, 'w')
  f:write(table.concat(r, '\n'), '\n')
  f:close()

end
