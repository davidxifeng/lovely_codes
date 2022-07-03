import Control.Monad

t :: Maybe Int
t = do
    s <- Just 2
    guard False
    return (s + 2)
