
-- Sun 19:54 Apr 26 优化Haskell代码到C的速度


{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

import GHC.Types
import GHC.Prim

collatzNext :: Int# -> Int#
collatzNext a =
    case andI# a 1# of
        0# -> quotInt# a 2#
        --_  -> (3# *# a +# 1#) `quotInt#` 2#
        _  -> ((uncheckedIShiftL# a 1#) +# a +# 1#) `quotInt#` 2#

collatzLen :: Int# -> Int#
collatzLen n = collatzIter n 0#
  where
    collatzIter 1# len = len
    collatzIter n len = collatzIter (collatzNext n) (len +# 1#)

main :: IO ()
main = do
    print (I# (find_max_len 1# 0#))

find_max_len :: Int# -> Int# -> Int#
find_max_len 1000000# max_len = max_len
find_max_len n max_len =
    case cn ># max_len of
        0# -> find_max_len nn max_len
        _ -> find_max_len nn cn
  where
    nn = n +# 1#
    cn = collatzLen n

