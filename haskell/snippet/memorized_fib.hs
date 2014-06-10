import Data.Function

import Data.List
import Data.Bits

const_time_fib n = round $ phi ** fromIntegral n / sq5
  where
    sq5 = sqrt 5 :: Double
    phi = (1 + sq5) / 2

main = print $ fast_fib 81839 -- 100020

max_known_prime_fib :: Integer
max_known_prime_fib = fast_fib 81839

digit_of_mkpf :: Int
digit_of_mkpf = length $ show max_known_prime_fib -- 17103

fast_fib :: Int -> Integer
fast_fib n = snd . foldl' fib' (1, 0) . dropWhile not $
            [testBit n k | k <- let s = bitSize n in [s-1,s-2..0]]
    where
        fib' (f, g) p
            | p         = (f*(f+2*g), ss)
            | otherwise = (ss, g*(2*f-g))
            where ss = f*f+g*g

memoized_fib :: Int -> Integer
memoized_fib = (map fib [0 ..] !!)
   where fib 0 = 0
         fib 1 = 1
         fib n = memoized_fib (n-2) + memoized_fib (n-1)

slow_fib :: Int -> Integer
slow_fib 0 = 0
slow_fib 1 = 1
slow_fib n = slow_fib (n-2) + slow_fib (n-1)

memoize :: (Int -> a) -> (Int -> a)
memoize f = (map f [0 ..] !!)

fibMemo :: Int -> Integer
fibMemo = fix (memoize . fib)

fib :: (Int -> Integer) -> Int -> Integer
fib f 0 = 1
fib f 1 = 1
fib f n = f (n - 1) + f (n - 2)
