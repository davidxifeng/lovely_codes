import Data.Bits

-- note: must use this code with -O

collatzNext :: Int -> Int
collatzNext a = r `quot` 2 -- 0.30 with -O3

--collatzNext a = r `shiftR` 1 -- 0.34 with -O3
--collatzNext a = r `div` 2 -- 1.39s with -O3
  where
    r = if a .&. 1 == 0 then a else 3 * a + 1

collatzLen :: Int -> Int
collatzLen n = collatzIter n 0
  where
    collatzIter 1 len = len
    collatzIter n len = collatzIter (collatzNext n) (len + 1)

main :: IO ()
main = print (find_max_len 1 0)

find_max_len :: Int -> Int -> Int
find_max_len 1000000 max_len = max_len
find_max_len n max_len =
    if cn > max_len
    then find_max_len nn cn
    else find_max_len nn max_len
  where
    nn = n + 1
    cn = collatzLen n
