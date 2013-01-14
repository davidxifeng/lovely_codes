import System.Environment
import System.Directory
import System.FilePath.Windows
import Control.Monad
import Data.List

-- 必须保证/*和*/是匹配的...这里满足这个条件
removeFirstComment :: String -> String
removeFirstComment [] = [] 
removeFirstComment ('/':'*':xs) = inComment xs
    where
        inComment [] = []
        inComment ('*':'/':xs') = xs'
        inComment (_:xs') = inComment xs'

removeFirstComment (x:xs) = x: removeFirstComment xs

getSourceFile :: FilePath -> IO [FilePath]
getSourceFile dir = (sort . filter isSourceFile) `liftM` getDirectoryContents dir
    where isSourceFile filepath = (snd $ splitExtension filepath)
        `elem`
         -- [".cpp", ".java", ".h", ".H", ".c", ".C"]
            [".c", ".hpp"]

processOneFile :: FilePath -> FilePath-> IO ()
processOneFile file dir = do
            let raw_file_name = dir ++ "\\" ++ file
            let temp_file_name = dir ++ "\\temp_" ++ file
            renameFile raw_file_name temp_file_name
            --putStrLn $ "rename " ++ raw_file_name ++ " to " ++ temp_file_name
            file_string <- readFile temp_file_name
            --putStrLn "lazy read temp file "
            writeFile raw_file_name (removeFirstComment file_string)
            putStrLn $ "write the processed file to " ++ raw_file_name
            removeFile temp_file_name
            --putStrLn $ "delete the temp file " ++ temp_file_name

processDirectoryFile :: [FilePath] -> FilePath -> IO ()
processDirectoryFile [] _ = return ()
processDirectoryFile (x:xs) path = do
    processOneFile x path
    processDirectoryFile xs path
    

isTrueSubDirectory :: FilePath -> Bool
isTrueSubDirectory x
    | x == "." = False
    | x == ".." = False
    | otherwise = True

getAllSubDirectory :: FilePath -> IO [FilePath]
getAllSubDirectory dir = do
    dc <- getDirectoryContents dir
    let tdc = filter isTrueSubDirectory dc
    let full_dc = map ((dir ++ "\\") ++) tdc
    sdc <- filterM doesDirectoryExist full_dc 
    return sdc


processDirectoryList :: [FilePath] -> IO ()
processDirectoryList [] = return ()
processDirectoryList (d:ds) = do
    is_valid_dir <- doesDirectoryExist d
    if is_valid_dir 
        then do
        --处理本目录下的文件
        putStrLn $ "now processing " ++ d
        file_list <- getSourceFile d
        processDirectoryFile file_list d
        --处理所有子目录
        subdir_list <- getAllSubDirectory d
        processDirectoryList subdir_list
        else do
        putStrLn $ d ++ " is not a valid directory"
        return ()
    processDirectoryList ds

main :: IO ()
main = do
    cur_dir <- getCurrentDirectory 
    let config_file = cur_dir ++ "\\dir_list.txt"
    dir_list_str <- readFile config_file
    mapM putStrLn $ lines dir_list_str  
    processDirectoryList $ lines dir_list_str

