import qualified Scripting.Lua as Lua

main = do
    lvm <- Lua.newstate
    Lua.openlibs lvm
    Lua.loadfile lvm "test.lua"
    Lua.registerhsfunction lvm "p" putStrLn
    Lua.call lvm 0 Lua.multret >>= print
    Lua.close lvm

