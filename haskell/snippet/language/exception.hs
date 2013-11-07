import Control.Exception

testBracket :: IO ()
testBracket = do
        bracket (return 8)
                (\i -> putStrLn $ "close action 1 " ++ show i)
                (\i -> do
                    putStrLn $ "do action 1 " ++ show i
                    bracket (return "hi") (\s -> putStrLn "close action 2")
                        (ac i)
                )

ac :: Int -> String -> IO ()
ac i s = do
        hd `handle` ac'
    where
        --hd :: IOException -> IO ()
        hd :: ArithException -> IO ()
        hd e = putStrLn $ show e ++ " handle ex"

        ac' = do
            putStrLn $ "action 2 " ++ show i
            --throwIO Overflow
            putStrLn $ "2nd " ++ s

main = putStrLn "exception reloaded"
