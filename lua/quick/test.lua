-- Sun 21:15 Apr 26
-- a simple console front end for game quick

local Board = require 'quick_console'
local cell_type = { '1', '2', '3', '4', '5', '6', '7', '8', '9' }

math.randomseed(1)
local board = Board(cell_type, 4, 3, 3)
--local board = Board.new(cell_type, 4, 3, 3)
print(board:render())
if board:can_click(2, 2) then
    local clear, l = board:click_on(2, 2)
    print(board:render())
end
if board:can_click(2, 1) then
    local clear, l = board:click_on(2, 1)
    print(board:render())
end

math.randomseed(1)
board:update()
print(board:render())
if board:can_click(2, 2) then
    local clear, l = board:click_on(2, 2)
    print(board:render())
end
if board:can_click(2, 1) then
    local clear, l = board:click_on(2, 1)
    print(board:render())
end
