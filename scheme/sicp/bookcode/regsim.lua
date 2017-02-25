-- 2017-02-26 Sun
-- sicp 5 make machine in Lua


local function make_machine(machine_define)

  return function (message)
    if message == 'set reg' then
      return function ()
        print 'set reg'
      end
    elseif message == 'get reg' then
      return function ()
        print 'get reg'
      end
    elseif message == 'start' then
      return function ()
        print 'start'
      end
    end
  end
end

local gcd_machine = make_machine {
  registers = {'a', 'b', 't'},
  ops = {},
  instruction_seq = {},
}

local function test(a, b)
  gcd_machine 'set reg' ('a', a)
  gcd_machine 'set reg' ('b', b)
  gcd_machine 'start'()
  return gcd_machine 'get reg' 'a'
end

test(a, b)
