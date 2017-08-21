Rebol [Title: "upvalue with context and bind"]
Red: 1
Red []

comment {
local function demo(n)
  return function () n = n + 1 return n end, function () n = n - 1 return n end
end

local inc, dec = demo(1)
print(inc()) -- 2
print(dec()) -- 1
print(inc()) -- 2
print(inc()) -- 3
print(dec()) -- 2

print '--- split line ---'

local inc2, dec2 = demo(5)
print(inc2()) -- 6
print(dec2()) -- 5
print(inc2()) -- 6
print(inc2()) -- 7
print(dec2()) -- 6

print(inc()) -- 3
print(dec()) -- 2
}

make-c: func [uvs spec1 body1 spec2 body2 /local ctx][
  ctx: make object! uvs
  reduce [func spec1 bind body1 ctx func spec2 bind body2 ctx]
]

make-demo: func [value] [
  make-c [n: value] ["inc"] [n: n + 1] ["dec"] [n: n - 1]
]

fs: make-demo 1
inc: first fs
dec: second fs

print [inc dec inc dec] ; 2 1 2 1

fs2: make-demo 5
inc2: first fs2
dec2: second fs2

print [inc2 dec2 inc2 dec2] ; 6 5 6 5
print [inc dec2 inc dec2] ; 2 4 3 3
