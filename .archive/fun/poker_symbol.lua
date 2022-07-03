local utf8_char = utf8.char

-- unicode扑克符号中的范围是 A - J, 多一个C, 然后是QK
-- 15张牌
local function add_symbol(start)
  local r = {}
  for i = 1, 14 do
    r[i] = utf8_char(start + i)
  end
  return r
end

-- 维基百科上, unicode中 符号表顺序
local StdCards = {
  ['黑桃'] = add_symbol(0x1F0A1 - 1),
  ['红桃'] = add_symbol(0x1F0B1 - 1),
  ['方块'] = add_symbol(0x1F0C1 - 1),
  ['梅花'] = add_symbol(0x1F0D1 - 1),
  ['牌背'] = utf8_char(0x1F0A0),

  ['花色'] = {
    utf8_char(0x2660), -- 黑桃
    utf8_char(0x2665), -- 红桃
    utf8_char(0x2666), -- 方块
    utf8_char(0x2663), -- 梅花
  },

  ['red_joker']   = utf8_char(0x1F0BF), -- CentOS 7上,这个不能正常显示
  ['black_joker'] = utf8_char(0x1F0CF),
  ['white_joker'] = utf8_char(0x1F0DF),
}

print(table.concat(StdCards['黑桃'], '  '))
print(table.concat(StdCards['红桃'], '  '))
print(table.concat(StdCards['方块'], '  '))
print(table.concat(StdCards['梅花'], '  '))
print(table.concat(StdCards['花色'], '  '))
-- will print
--[[
🂡  🂢  🂣  🂤  🂥  🂦  🂧  🂨  🂩  🂪  🂫  🂬  🂭  🂮
🂱  🂲  🂳  🂴  🂵  🂶  🂷  🂸  🂹  🂺  🂻  🂼  🂽  🂾
🃁  🃂  🃃  🃄  🃅  🃆  🃇  🃈  🃉  🃊  🃋  🃌  🃍  🃎
🃑  🃒  🃓  🃔  🃕  🃖  🃗  🃘  🃙  🃚  🃛  🃜  🃝  🃞
♠  ♥  ♦  ♣
--]]
