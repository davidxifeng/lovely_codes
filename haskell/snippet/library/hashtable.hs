import qualified Data.HashTable.IO as H

--type HashTable k v = H.BasicHashTable k v
type HashTable k v = H.CuckooHashTable k v

foo :: IO (HashTable Int Int)
foo = do
    ht <- H.new
    H.insert ht 1 1
    H.insert ht 2 521
    H.insert ht 3 8725
    s <- H.lookup ht 1
    putStrLn $ "s is " ++ show s
    s <- H.lookup ht 3
    putStrLn $ "s is " ++ show s
    s <- H.lookup ht 5
    putStrLn $ "s is " ++ show s
    return ht
