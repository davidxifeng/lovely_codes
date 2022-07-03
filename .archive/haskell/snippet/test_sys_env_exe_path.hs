import System.Environment.Executable

main = getScriptPath >>= putStrLn . show
