{-# LANGUAGE DeriveDataTypeable, GeneralizedNewtypeDeriving, TemplateHaskell #-}
module Main where

import Prelude                 hiding (head)

import Control.Monad           (msum)
import Data.Data               (Data, Typeable)
import Data.Monoid             (mconcat)
import Data.Text               (pack)
import Happstack.Server        ( Response, ServerPartT, ok, toResponse, simpleHTTP
                               , nullConf, seeOther, dir, notFound, seeOther)
import Text.Blaze.Html4.Strict ( (!), html, head, body, title, p, toHtml
                               , toValue, ol, li, a)
import Text.Blaze.Html4.Strict.Attributes (href)
import Web.Routes              ( PathInfo(..), RouteT, showURL
                               , runRouteT, Site(..), setDefault, mkSitePI)
import Web.Routes.TH           (derivePathInfo)
import Web.Routes.Happstack    (implSite)

newtype ArticleId
    = ArticleId { unArticleId :: Int }
      deriving (Eq, Ord, Enum, Read, Show, Data, Typeable, PathInfo)

data Sitemap
    = Home
    | Article ArticleId
      deriving (Eq, Ord, Read, Show, Data, Typeable)

$(derivePathInfo ''Sitemap)

route :: Sitemap -> RouteT Sitemap (ServerPartT IO) Response
route url =
    case url of
      Home                -> homePage
      (Article articleId) -> articlePage articleId

homePage :: RouteT Sitemap (ServerPartT IO) Response
homePage =
    do articles <- mapM mkArticle [(ArticleId 1) .. (ArticleId 10)]
       ok $ toResponse $
          html $ do
            head $ title $ (toHtml "Welcome Home!")
            body $ do
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
                   p $ do toHtml "Click "
                          a ! href (toValue homeURL) $ toHtml "here"
                          toHtml " to return home."

site :: Site Sitemap (ServerPartT IO Response)
site =
       setDefault Home $ mkSitePI (runRouteT route)

main :: IO ()
main = simpleHTTP nullConf $
       msum [ dir "favicon.ico" $ notFound (toResponse ())
            , implSite (pack "http://localhost:8000") (pack "/route") site
            , seeOther "/route" (toResponse ())
            ]

