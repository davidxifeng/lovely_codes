import System.IO.Unsafe
import System.Random(getStdRandom, randomR)

-- 会得到3个不同的随机数
randomNorm :: IO Float
randomNorm = getStdRandom (randomR (0, 1))

main :: IO ()
main = do
    print $ unsafePerformIO randomNorm
    print $ unsafePerformIO randomNorm
    print $ unsafePerformIO randomNorm

-- {-# NOINLINE randomNorm' #-}
-- 有没有这个inline 结果都是一样的, 获取三次随机数都一样
randomNorm' :: Float
randomNorm' = unsafePerformIO (getStdRandom (randomR (0, 1)))

main' :: IO ()
main' = do
    print randomNorm'
    print randomNorm'
    print randomNorm'
