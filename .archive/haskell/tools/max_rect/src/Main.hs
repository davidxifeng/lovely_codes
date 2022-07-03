{-# LANGUAGE OverloadedStrings #-}
module Main
    ( main
    ) where
import Network.Wai
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import Network.Wai.Application.Static
import Network.Wai.UrlMap
import Control.Applicative ((<|>))
import qualified Web.Scotty as S
import Control.Monad.Trans (liftIO)
import Data.Time (getZonedTime)

--import UtilityTypes
import RectTest (api)


genLayout :: Request -> (Response -> IO ResponseReceived) -> IO ResponseReceived
genLayout _ r = r $ responseLBS status200 [("Content-Type", "text/plain")] "[]"

app :: Application -> Application
app sco = mapUrls $
    mount "api" genLayout
    <|> mount "x" sco
    <|> mount "file" rootApp
    <|> mount "project.json" pj
    <|> mountRoot index

pj :: Application
pj _ r = r $ responseFile
    status200
    [("Content-Type", "application/json")]
    "www/project.json"
    Nothing

index :: Application
index _ r = r $ responseFile
    status200
    [("Content-Type", "text/html")]
    "www/index.html"
    Nothing

rootApp :: Application
rootApp = staticApp (defaultWebAppSettings "www")

myScotty :: S.ScottyM ()
myScotty = do
    S.get "/api" $ S.json =<< liftIO api
    S.get "/time" $ S.json =<< liftIO getZonedTime

main :: IO ()
main = do
    putStrLn "http://localhost:8080/"
    run 8080 . app =<< S.scottyApp myScotty
