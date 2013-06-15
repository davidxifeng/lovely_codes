{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
-- | A co-routine monad.
module Coroutine (
        CoroutineT(runCoroutineT),
        Result(..),
        yield
    ) where

import Control.Monad
import Control.Monad.Trans


data Result i o m a = Yield o (i -> CoroutineT i o m a) | Result a

-- | Co-routine monad transformer
--
--   * i = input value returned by yield
--
--   * o = output value, passed to yield
--
--   * m = next monad in stack
--
--   * a = monad return value
newtype CoroutineT i o m a = CoroutineT {
        runCoroutineT :: m (Result i o m a)
    }

instance Monad m => Functor (CoroutineT i o m) where
    fmap = liftM

instance Monad m => Monad (CoroutineT i o m) where
    return a = CoroutineT $ return $ Result a
    f >>= g = CoroutineT $ do
        res1 <- runCoroutineT f
        case res1 of
            Yield o c -> return $ Yield o (\i -> c i >>= g)
            Result a  -> runCoroutineT (g a)
    -- Pass fail to next monad in the stack
    fail err = CoroutineT $ fail err

instance MonadTrans (CoroutineT i y) where
    lift m = CoroutineT $ do
        r <- m
        return $ Result r

instance MonadIO m => MonadIO (CoroutineT i o m) where
    liftIO m = CoroutineT $ do
        r <- liftIO m
        return $ Result r

-- | Suspend processing, returning a @o@ value and a continuation to the caller
yield :: Monad m => o -> CoroutineT i o m i
yield o = CoroutineT $ return $ Yield o (\i -> CoroutineT $ return $ Result i)

