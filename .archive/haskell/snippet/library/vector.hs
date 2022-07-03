import Data.Vector (Vector, (!), (!?))
import Data.Vector.Mutable (IOVector, STVector)
import qualified Data.Vector as V
import qualified Data.Vector.Mutable as MV

getVector :: IO (Vector String, IOVector String)
getVector = do
    v <- MV.new 2
    MV.write v 0 "hi"
    MV.write v 1 "one"
    --r <- V.freeze v
    r <- V.unsafeFreeze v
    return (r, v)

main :: IO ()
main = do
    (iv, mv) <- getVector
    V.mapM_ putStrLn iv
    MV.write mv 0 "hello"
    V.mapM_ putStrLn iv
    putStrLn $ show $ iv !? 3 -- safe index maybe
    return ()

