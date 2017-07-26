/*

-- Lua

local x = 2
print(x)

function f()
  print(x) -- upvalue x, 2
  local x = 5
  print(x) -- local x, 5
end
f()
*/
let x = 2;
console.log(x);

function f() {
  console.log(x); // hoist x, Temporal Dead Zone, ReferenceError
  let x = 1;
  console.log(x);
}
f();
