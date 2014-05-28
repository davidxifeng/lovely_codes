
-- | input 2 "abc"
-- return ["a","b","ab","c","ac","bc"]
subsequences_n :: Int -> [a] -> [[a]]
subsequences_n n = go
  where
    go [] = []
    go (x:xs) =
        let f ys r = if length ys >= n then ys:r else ys : (x : ys) : r
        in [x] : foldr f [] (go xs)

