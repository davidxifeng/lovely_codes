{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -F -pgmFtrhsx #-}
module Main where

import Control.Applicative ((<$>))
import Control.Monad       (msum)
import Data.Text           (empty, pack)
import Happstack.Server
import Happstack.Server.HSP.HTML
import Web.Routes
import Web.Routes.TH
import Web.Routes.XMLGenT
import Web.Routes.Happstack
data SiteURL = Monkeys Int deriving (Eq, Ord, Read, Show)

$(derivePathInfo ''SiteURL)

monkeys :: Int -> RouteT SiteURL (ServerPartT IO) Response
monkeys n =
    do html <- defaultTemplate "monkeys" () $
        <%>
         <p>You have <% show n %> monkeys.</p>
         <p>Click <a href=(Monkeys (succ n))>here</a> for more.</p>
        </%>
       ok $ (toResponse html)
route :: SiteURL -> RouteT SiteURL (ServerPartT IO) Response
route url =
    case url of
      (Monkeys n) -> monkeys n

site :: Site SiteURL (ServerPartT IO Response)
site = setDefault (Monkeys 0) $ mkSitePI (runRouteT route)

main :: IO ()
main = simpleHTTP nullConf $
  msum [ dir "favicon.ico" $ notFound (toResponse ())
       , implSite (pack "http://localhost:8000") empty site
       ]
