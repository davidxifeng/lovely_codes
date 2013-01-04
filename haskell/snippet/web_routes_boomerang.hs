{-# LANGUAGE DeriveDataTypeable, GeneralizedNewtypeDeriving, TemplateHaskell, 
  TypeOperators, OverloadedStrings #-}
module Main where

import Prelude                 hiding (head, id, (.))
import Control.Category        (Category(id, (.)))

import Control.Monad           (msum)
import Data.Data               (Data, Typeable)
import Data.Monoid             (mconcat)
import Data.String             (fromString)
import Data.Text               (Text)
import Happstack.Server        ( Response, ServerPartT, ok, toResponse, simpleHTTP
                               , nullConf, seeOther, dir, notFound, seeOther)
import Text.Blaze.Html4.Strict ( (!), html, head, body, title, p, toHtml
                               , toValue, ol, li, a)
import Text.Blaze.Html4.Strict.Attributes (href)
import Text.Boomerang.TH       (derivePrinterParsers)
import Web.Routes              ( PathInfo(..), RouteT, showURL
                               , runRouteT, Site(..), setDefault, mkSitePI)
import Web.Routes.TH           (derivePathInfo)
import Web.Routes.Happstack    (implSite)
import Web.Routes.Boomerang

newtype ArticleId
    = ArticleId { unArticleId :: Int }
      deriving (Eq, Ord, Enum, Read, Show, Data, Typeable, PathInfo)

data Sitemap
    = Home
    | Article ArticleId
    | UserOverview
    | UserDetail Int Text
      deriving (Eq, Ord, Read, Show, Data, Typeable)

$(derivePrinterParsers ''Sitemap)

sitemap :: Router () (Sitemap :- ())
sitemap =
    (  rHome
    <> rArticle . (lit "article" </> articleId)
    <> lit "users" . users
    )
    where
      users =  rUserOverview
            <> rUserDetail </> int . lit "-" . anyText

articleId :: Router () (ArticleId :- ())
articleId =
    xmaph ArticleId (Just . unArticleId) int
route :: Sitemap -> RouteT Sitemap (ServerPartT IO) Response
route url =
    case url of
      Home                  -> homePage
      (Article articleId)   -> articlePage articleId
      UserOverview          -> userOverviewPage
      (UserDetail uid name) -> userDetailPage uid name

homePage :: RouteT Sitemap (ServerPartT IO) Response
homePage =
    do articles     <- mapM mkArticle [(ArticleId 1) .. (ArticleId 10)]
       userOverview <- showURL UserOverview
       ok $ toResponse $
          html $ do
            head $ title $ "Welcome Home!"
            body $ do
              a ! href (toValue userOverview) $ "User Overview"
              ol $ mconcat articles
    where
      mkArticle articleId =
          do url <- showURL (Article articleId)
             return $ li $ a ! href (toValue url) $
                        toHtml $ "Article " ++ (show $ unArticleId articleId)

articlePage :: ArticleId -> RouteT Sitemap (ServerPartT IO) Response
articlePage (ArticleId articleId) =
    do homeURL <- showURL Home
       ok $ toResponse $
          html $ do
            head $ title $ (toHtml $ "Article " ++ show articleId)
            body $ do
                   p $ toHtml $ "You are now reading article " ++ show articleId
                   p $ do "Click "
                          a ! href (toValue homeURL) $ "here"
                          " to return home."

userOverviewPage :: RouteT Sitemap (ServerPartT IO) Response
userOverviewPage =
    do users <- mapM mkUser [1 .. 10]
       ok $ toResponse $
          html $ do
            head $ title $ "Our Users"
            body $ do
              ol $ mconcat users
    where
      mkUser userId =
          do url <- showURL (UserDetail userId (fromString $ "user " ++ show userId))
             return $ li $ a ! href (toValue url) $
                        toHtml $ "User " ++ (show $ userId)

userDetailPage :: Int -> Text -> RouteT Sitemap (ServerPartT IO) Response
userDetailPage userId userName =
    do homeURL <- showURL Home
       ok $ toResponse $
          html $ do
            head $ title $ (toHtml $ "User " <> userName)
            body $ do
                   p $ toHtml $ "You are now view user detail page for " <> userName
                   p $ do "Click "
                          a ! href (toValue homeURL) $ "here"
                          " to return home."

site :: Site Sitemap (ServerPartT IO Response)
site =
       setDefault Home $ boomerangSite (runRouteT route) sitemap

main :: IO ()
main = simpleHTTP nullConf $
       msum [ dir "favicon.ico" $ notFound (toResponse ())
            , implSite "http://localhost:8000" "/route" site
            , seeOther ("/route/" :: String) (toResponse ())
            ]

