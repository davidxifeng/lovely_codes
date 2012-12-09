import Data.Tree

import Data.Sequence
-- Sun Dec  9 15:04:56 CST 2012

test :: Int -> (String, [Int])
test 0 = (show 0, [0])
test n = (show n, [1..n-1])


mytree :: Int -> Tree String
mytree n = unfoldTree test n



seq0 :: Seq Int
seq0 = empty

seq1 :: Seq Int
seq1 = singleton 1

addLeft :: Int -> Seq Int -> Seq Int
addLeft = (<|)

addRight :: Seq Int -> Int -> Seq Int
addRight = (|>)

concatSeq :: Seq a -> Seq a -> Seq a
concatSeq a b = a >< b

seq3 :: Seq Int
seq3 = addLeft 2 seq1 >< addRight  seq1 3

seq4 :: Seq Int
seq4 = seq3 >< fromList [9..15]
