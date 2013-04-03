
ack :: Integer -> Integer -> Integer
ack 0 y = 1 + y
ack x 0 = ack (x-1) 1
ack x y = ack (x - 1) (ack x (y - 1))


ack2 :: Integer -> Integer -> Integer
ack2 x 0 = 0
ack2 x 1 = 2
ack2 0 y = 2 * y
ack2 x y = ack (x - 1) (ack x (y - 1))

arg_list :: [(Integer, Integer)]
arg_list = [(x, y)| x <- [0..3], y <- [0..4]]

ack_list :: [Integer]
ack_list = map (\(x, y) -> ack x y) arg_list

display (x, y) = do
    --putStrLn $ "ack " ++ show x ++ " " ++ show y ++ " is " ++ (show $ ack x y)
    putStrLn $ "ack " ++ show x ++ " " ++ show y ++ " is " ++ (show $ ack2 x y)

main = do
    -- putStrLn $ show ack_list
    mapM_ display arg_list
