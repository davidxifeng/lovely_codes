module Main (main) where

import System.Environment

qsort [] = []
qsort (a:as) = qsort left ++ [a] ++ qsort right
    where (left, right) = (filter (<= a) as, filter (>a) as)

test = print (qsort [8, 4, 0, 3, 1, 23, 11, 18])


main :: IO ()
main = do
    getArgs >>= print
    test
