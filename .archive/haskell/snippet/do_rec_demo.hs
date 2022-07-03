{-# LANGUAGE DoRec #-}

justOnes = do { rec { xs <- Just (1:xs) }
              ; return $ take 5 (map negate xs) }
