{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
import           Control.Monad.IO.Class  (liftIO)
import           Database.Persist.Postgresql
import           Database.Persist.TH
import Data.Maybe (fromJust)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
    name String
    age Int Maybe
    deriving Show
BlogPost
    title String
    authorId PersonId
    age Int Maybe -- test migrate
    deriving Show
|]

main :: IO ()
main = do
        withPostgresqlPool connStr 8 x
        return ()
    where
        connStr = "host=localhost port=5432 dbname=postgres user=david password=dev"

x :: ConnectionPool -> IO ()
x = runSqlPersistMPool $ do
    runMigration migrateAll

    --johnId <- insert $ Person "John Doe" $ Just 35
    r <- selectFirst [PersonAge ==. Just 39] []
    liftIO $ print $ fromJust r
    liftIO $ putStrLn "\n"

    --let johnId = entityKey $ fromJust r
    let johnId = Key (PersistInt64 8)

    oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 2]
    --liftIO $ print (oneJohnPost :: [Entity BlogPost])
    let t1 = (entityVal $ head (oneJohnPost :: [Entity BlogPost]))
    liftIO $ print t1
    liftIO $ putStrLn "\n"
    --let johnId = fromJust r
    --janeId <- insert $ Person "Jane Doe" Nothing

    --insert $ BlogPost "love you My first post" johnId
    --insert $ BlogPost "One more for good measure" johnId

    john <- get johnId
    liftIO $ print (john :: Maybe Person)

    --delete janeId
    --deleteWhere [BlogPostAuthorId ==. johnId]

