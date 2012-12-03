module FileUtility
(
    copyDir,
    whenM
)
where

import Control.Monad hiding(join)
import System.Directory
import System.FilePath((</>))
import Control.Applicative((<$>))
import Control.Exception(throw)

import Data.List(isPrefixOf, intercalate, intersperse)
 
whenM :: Monad m => m Bool -> m () -> m ()
--whenM :: IO Bool -> IO () -> IO ()
whenM s r = s >>= flip when r

-- | 递归copy文件夹,会覆盖目标文件夹中已有的文件,过滤.svn文件夹,example文件夹
copyDir ::  FilePath -> FilePath -> IO ()
copyDir src dst = do
    whenM (not <$> doesDirectoryExist src) $
        throw (userError "source does not exist")
  --whenM (doesFileOrDirectoryExist dst) $
    --throw (userError "destination already exists")

    putStrLn $ "copying\n" ++ src ++ "\nto\n" ++ dst
    dst_exist <- doesDirectoryExist dst
    if dst_exist
        then putStrLn "dest directory already exist, merge folders"
        else do
            putStrLn "dest directory doesn't exist, copy folders"
            createDirectory dst
    content <- getDirectoryContents src
    let xs = filter (`notElem` [".", "..", ".svn", "example"]) content
    forM_ xs $ \name -> do
        let srcPath = src </> name
        let dstPath = dst </> name
        isDirectory <- doesDirectoryExist srcPath
        if isDirectory
            then copyDir srcPath dstPath
            else copyFile srcPath dstPath


-- doesFileOrDirectoryExist :: FilePath -> IO Bool
-- doesFileOrDirectoryExist x = orM [doesDirectoryExist x, doesFileExist x]
-- orM :: [IO Bool] -> IO Bool
-- orM xs = or <$> sequence xs

spanList :: ([a] -> Bool) -> [a] -> ([a], [a])

spanList _ [] = ([],[])
spanList func list@(x:xs) =
    if func list
       then (x:ys,zs)
       else ([],list)
    where (ys,zs) = spanList func xs
    
startswith :: Eq a => [a] -> [a] -> Bool
startswith = isPrefixOf    

{- | Similar to Data.List.break, but performs the test on the entire remaining
list instead of just one element.
-}
breakList :: ([a] -> Bool) -> [a] -> ([a], [a])
breakList func = spanList (not . func)

{- | Given a delimiter and a list (or string), split into components.

Example:

> split "," "foo,bar,,baz," -> ["foo", "bar", "", "baz", ""]

> split "ba" ",foo,bar,,baz," -> [",foo,","r,,","z,"]
-}

split :: Eq a => [a] -> [a] -> [[a]]
split _ [] = []
split delim str =
    let (firstline, remainder) = breakList (startswith delim) str
        in 
        firstline : case remainder of
                                   [] -> [[]]
                                   x -> if x == delim
                                        then []
                                        else split delim 
                                                 (drop (length delim) x)

{- | Given a delimiter and a list of items (or strings), join the items
by using the delimiter.

Example:

> join "|" ["foo", "bar", "baz"] -> "foo|bar|baz"
-}
join :: [a] -> [[a]] -> [a]
join delim l = concat (intersperse delim l)
-- join delim l = intercalate delim l
-- join = intercalate

replaceString :: Eq a => [a] -> [a] -> [a] -> [a]
replaceString old new l = join new . split old $ l

replace :: Eq a => [a] -> [a] -> [a] -> [a]
replace = replaceString