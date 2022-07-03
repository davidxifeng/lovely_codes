import System.Random

main =
    do { let g = mkStdGen 43
       ; let s = take 3 (randomStuff g)
       ; mapM_ print s
       }

randomStuff :: RandomGen g => g -> [[Float]]
randomStuff g = work (randomRs (0.0, 1.0) g)

work :: [Float] -> [[Float]]
work (r:rs) =
    let n = truncate (r * 7.0) + 1
        (xs,ys) = splitAt n rs
    in xs : work ys
