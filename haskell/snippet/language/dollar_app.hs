-- {-# LANGUAGE Rank2Types #-}
module Main (main) where

app :: Int -> IO ()
app i = do
    putStr "raw app action "
    print i


main :: IO ()
main = ts t

data Test
    = Test
    { test :: App
    }

t :: Test
t = Test
    { test = ($ app)
    }

type RawApp = Int -> IO ()
--type App = (RawApp -> IO ()) -> IO ()
type App = ((Int -> IO ()) -> IO ()) -> IO ()


ts :: Test -> IO ()
--ts (Test arg) = arg $ \ fa -> fa 521
ts (Test arg) = arg ff

ff :: (Int -> IO ()) -> IO ()
ff ac = ac 521
