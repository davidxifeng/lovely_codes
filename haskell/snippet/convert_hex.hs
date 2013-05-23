s = "__(0x0001, life,test,0x0002,love)"


-- 简单的读入hex字符串,返回dec字符串
hex2dec :: String -> String
hex2dec [] = []
hex2dec s = show (read s :: Integer)

-- a simple function just work for attributes.py
r :: String -> String
r [] = []
r ('0':'x':a:b:c:d:cs) = (hex2dec ("0x"++a:b:c:d:[])) ++ (r cs)
r (c:cs) = c:(r cs)

main :: IO ()
main = do
        input <- readFile "attributes.py"
        writeFile "attributes_out.py" (r input)
