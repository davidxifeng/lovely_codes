--{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Data.Char
import Control.Monad.Trans.Identity
import Control.Monad.Identity

data Result i o m a = Yield o (i -> CoroutineT i o m a) | Result a


-- | Co-routine monad transformer
--   * i = input value returned by yield
--   * o = output value, passed to yield
--   * m = next monad in stack
--   * a = monad return value
--data CoroutineT i o m a = CoroutineT {
newtype CoroutineT i o m a = CoroutineT {
        runCoroutineT :: m (Result i o m a)
    }

-- | Suspend processing, returning a @o@ value and a continuation to the caller
yield :: Monad m =>
        o -> CoroutineT i o m i
yield o = CoroutineT $ return $ Yield o (\i -> CoroutineT $ return $ Result i)

instance Monad m => Monad (CoroutineT i o m) where

    return a = CoroutineT $ return $ Result a

    f >>= g  = CoroutineT $ do
        res1 <- runCoroutineT f
        case res1 of
            Yield o c -> return $ Yield o (\i -> c i >>= g)
            Result a  -> runCoroutineT (g a)

    -- Pass fail to next monad in the stack
    fail err = CoroutineT $ fail err




type Question = String
data Answer = Y | N deriving Eq

type Expert a = CoroutineT Answer Question Identity a

data Fruit
    = Apple
    | Kiwifruit
    | Banana
    | Orange
    | Lemon
    deriving Show

test :: Int -> CoroutineT Bool Int Identity String
test st = do
        loop st
    where
        loop :: Int -> CoroutineT Bool Int Identity String
        loop i = do
            s <- yield i
            if s
                then return "stop"
                else loop (i + 1)

tr :: IO ()
tr = do
        run (test 5)
    where
        run :: CoroutineT Bool Int Identity String -> IO ()
        run crt = handle $ runIdentity $ runCoroutineT crt

        handle :: Result Bool Int Identity String -> IO ()
        handle (Yield q cont) = do
            putStrLn $ "q is " ++ show q
            if q == 12
                then run (cont True)
                else run (cont False)

        handle (Result s) = do
            putStrLn $ "done r is " ++ s

--identifyFruit :: CoroutineT Answer Question Identity Fruit
identifyFruit :: Expert Fruit
identifyFruit = do
    yellow <- yield "Is it yellow?"
    if yellow == Y then do
        long <- yield "Is it long?"
        if long == Y then
            return Banana
          else
            return Lemon
      else do
        orange <- yield "Is it orange?"
        if orange == Y then
           return Orange
         else do
           fuzzy <- yield "Is it fuzzy?"
           if fuzzy == Y then
               return Kiwifruit
             else
               return Apple
main :: IO ()
main = do
    putStrLn $ "Expert system for identifying fruit"
    run identifyFruit
  where
    run :: Expert Fruit -> IO ()
    run exp = handle $ runIdentity $ runCoroutineT exp

    handle (Yield q cont) = do
        putStrLn q
        l <- getLine
        case map toLower l of
            "y"   -> run $ cont Y
            "yes" -> run $ cont Y
            "n"   -> run $ cont N
            "no"  -> run $ cont N
            _   -> putStrLn "Please answer 'yes' or 'no'" >> handle (Yield q cont)
    handle (Result fruit) = do
        putStrLn $ "The fruit you have is: "++show fruit


