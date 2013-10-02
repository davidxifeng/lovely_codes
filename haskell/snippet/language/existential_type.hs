{-# LANGUAGE ExistentialQuantification #-}



f :: Int -> Int -> Int
f i = (+) (3 * i)

g :: (Int -> Int) -> Int -> IO ()
g f i = do
        putStrLn $ show $ f i

t = g (f 5) 8 -- 23

data Test
        = Test
        | forall msg . Integral msg => TestInt msg
        | forall msg . TestAll msg

