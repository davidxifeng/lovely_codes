{-# LANGUAGE Rank2Types #-}

data A
    = A
    { a :: Int
    , f :: (Show s) => s -> IO ()
    }

data B
    = B
    { b :: Int
    , g :: ((Show s) => s -> IO ())
    }

ta :: A
ta = A { a = 5
       , f = \s -> putStrLn (show s ++ "\nwhat the fuck")
       }


tb :: A -> B
tb v = B { b = a v
         , g = f v
         }

tb2 :: ((Show s ) => s -> IO ())-> B
tb2 f = B { b = 8
          , g = f
          }
