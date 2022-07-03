import Data.Char

-- 测试 fc3

t3f x = x ^ 2
t3g x y = x + y

t3 = fc3 t3f t3g 1 2
t3' = t3f (t3g 1 2)

-- 测试一阶的函数组合 B组合子

h :: Char -> Int
h x = ord x

j :: String -> Char
j s = if null s then 'L' else head s

tfc2 :: String -> Int
tfc2 = h . j
test_fc1 = tfc2 "hello"
test_n1 = h (j "hello")

fc1 :: (b -> c) -> (a -> b) -> a -> c
fc1 = (.)

-- 测试fc2
fc2 :: (a -> b -> c) -> a -> (a1 -> b) -> a1 -> c
fc2 = (.) (.)

f :: Int -> Int -> Float
f a b = fromIntegral $ a + b
g :: Char -> Int
g x = ord x

t2 = fc2 f 2 g 'c'
t2' = f 2 (g 'c')
test = (.)(.) (\x y ->  x + y ) 2 (\x -> ord x) 'c'

fc3 :: (b -> c) -> (a -> a1 -> b) -> a -> a1 -> c
fc3 = (.) (.) (.)

fc4 :: (a -> a1 -> b -> c) -> a -> a1 -> (a2 -> b) -> a2 -> c
fc4 = (.)(.)(.)(.)

fc5 :: (b1 -> c) -> (b -> b1) -> (a -> b) -> a -> c
fc5 = (.)(.)(.)(.)(.)

fc6 :: (b -> b1 -> c) -> (a -> b) -> a -> (a1 -> b1) -> a1 -> c
fc6 = (.)(.)(.)(.)(.)(.)

fc7 :: (a -> b -> c) -> a -> (a1 -> a2 -> b) -> a1 -> a2 -> c
fc7 = (.)(.)(.)(.)(.)(.)(.)

fcn :: (b -> c) -> (a -> a1 -> a2 -> a3 -> b) -> a -> a1 -> a2 -> a3 -> c
fcn = ((.) . (.)) . ((.).(.))

fcxy :: (b1 -> b -> c) -> (a -> a1 -> b1) -> a -> a1 -> (a2 -> a3 -> b) -> a2 -> a3 -> c
fcxy = (.)(.)(.)(.)(.)(.)(.) (.) ((.) . (.)) . (( . ) . ( . ))

