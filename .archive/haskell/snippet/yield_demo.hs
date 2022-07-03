--{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Data.Char
import Control.Monad.Trans (liftIO)
import Control.Monad.Trans.Identity
import Control.Monad.Identity
import Coroutine


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

test :: Int -> CoroutineT Bool Int IO String
test st = do
        liftIO $ putStrLn "enter test"
        loop st
    where
        loop :: Int -> CoroutineT Bool Int IO String
        loop i = do
            s <- yield i
            if s
                then return "stop"
                else loop (i + 1)

tr :: IO ()
tr = do
        run (test 5)
    where
        run :: CoroutineT Bool Int IO String -> IO ()
        run crt = do
            r <- runCoroutineT crt
            handle r

        handle :: Result Bool Int IO String -> IO ()
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


