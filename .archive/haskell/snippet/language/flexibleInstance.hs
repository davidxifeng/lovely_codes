{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}

class David a where
        getTest :: Int -> a

instance David [Char] where
        getTest :: Int -> String
        getTest 1 = "one"
        getTest 2 = "two"
        getTest _ = "more"

instance David Float where
        getTest 1 = 1.1
        getTest 2 = 2.2
        getTest _ = 3.000002

