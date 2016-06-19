-- Sun 17:41 Jun 19

local terralib = terralib

local res_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/7.3.0"
local sys_root = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk"

terralib.includepath = sys_root .. '/usr/include;' .. terralib.includepath

local C = terralib.includec 'stdio.h'
local zlib = terralib.includec 'zlib.h'
terralib.linklibrary('/usr/lib/libz.1.dylib')

local terra test (argc : int, argv : &&int8)
  var a : int = 3
  var c = 3.14

  C.printf("hello terra %d %lf\n", a, c)
  for i = 0, argc do
    C.printf("[%d] argv is %s\n", i, argv[i])
  end
  C.printf("zlib version %s\n", zlib.zlibVersion())

  return 0
end

--[[
local inspect = require 'inspect'
local zlv = inspect(zlib.zlibVersion, { process = function(item, path)
  if path[#path] ~= inspect.METATABLE then return item end
end})
print('zlib version is:', zlv)
--]]

local target = terralib.newtarget { Triple = "x86_64-apple-macosx10.11.0" }
terralib.saveobj('test.prog', 'executable', { main = test }, {'-l', 'z'}, target)
terralib.saveobj('test.o', { test = test }, {}, target)
