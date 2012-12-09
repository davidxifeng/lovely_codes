import Control.Exception
import Data.Either
import Prelude hiding(catch)

{-
- Sun Dec  9 02:57:43 CST 2012
-}

-- 从IO中捕获异常,捕捉到异常后放到either错误中,正常就直接返回
mytry :: IO ()
mytry = do
	result <- try (evaluate (div 5 2)) :: IO (Either SomeException Int)
	case result of
		 Left ex -> putStrLn $ "ex: " ++ show ex
		 Right val -> putStrLn $ "value: " ++ show val

-- 需要hiding prelude中的catch函数
mycatch :: IO ()
mycatch = catch (print $ div 2 0) handler
	where
	handler :: SomeException -> IO ()
	handler ex = putStrLn $ "catch ex " ++ show ex
