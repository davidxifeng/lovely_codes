import System.Directory
import System.FilePath
import Control.Monad.Reader
import Control.Monad.State
import Control.Monad(forM, liftM)

listDirectory :: FilePath -> IO [String]
listDirectory = liftM (filter nd) . getDirectoryContents
    where
    nd p = p /= "." && p /= ".."

data AppConfig = AppConfig {
    cfgMaxDepth :: Int
} deriving (Show)

data AppState = AppState {
    stDeepestReached :: Int
} deriving (Show)

type App = ReaderT AppConfig (StateT AppState IO)

runApp :: App a -> Int -> IO (a, AppState)
runApp k maxDepth = 
        let config = AppConfig maxDepth
            state  = AppState 0
        in runStateT (runReaderT k config) state

justCount :: Int -> FilePath -> App [(FilePath, Int)]
justCount curDepth path = do
    contents <- liftIO . listDirectory $ path
    cfg <- ask
    rest <- forM contents $ \name -> do
        let np = path </> name
        isDir <- liftIO $ doesDirectoryExist np
        if isDir && curDepth < cfgMaxDepth cfg
            then do
                let newDepth = curDepth + 1
                st <- get
                when (stDeepestReached st < newDepth) $
                    put st { stDeepestReached = newDepth }
                justCount newDepth np
            else do
                return []
    return $ (path, length contents ) : concat rest

main :: IO ()
main = do
    (r, s) <- runApp (justCount 0 "..") 3
    putStrLn $ show s
    forM_  r (putStrLn . show)

