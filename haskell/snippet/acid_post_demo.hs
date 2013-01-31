{-# LANGUAGE DeriveDataTypeable, GeneralizedNewtypeDeriving, RecordWildCards
  , TemplateHaskell, TypeFamilies, OverloadedStrings #-}
module Main where

import Control.Applicative  ((<$>), optional)
import Control.Exception    (bracket)
import Control.Monad        (msum, mzero)
import Control.Monad.Reader (ask)
import Control.Monad.State  (get, put)
import Control.Monad.Trans  (liftIO)
import Data.Acid            (AcidState, Update, Query, makeAcidic )
import Data.Acid.Advanced   (update', query')
import Data.Acid.Local      (openLocalState, createCheckpointAndClose)
import Data.Data            (Data, Typeable)
import Data.IxSet           ( Indexable(..), IxSet(..), (@=), Proxy(..), getOne
                            , ixFun, ixSet )
import qualified Data.IxSet as IxSet
import Data.SafeCopy        (SafeCopy, base, deriveSafeCopy)
import Data.Text            (Text)
import Data.Text.Lazy       (toStrict)
import qualified Data.Text  as Text
import Data.Time            (UTCTime(..), getCurrentTime)
import Happstack.Server     ( ServerPart, Method(POST, HEAD, GET), Response, decodeBody
                            , defaultBodyPolicy, dir, lookRead, lookText, method
                            , notFound, nullConf, nullDir, ok, seeOther, simpleHTTP
                            , toResponse)
import           Text.Blaze.Html ((!), Html)
import qualified Text.Blaze.Html4.Strict as H
import qualified Text.Blaze.Html4.Strict.Attributes as A


newtype PostId = PostId { unPostId :: Integer }
    deriving (Eq, Ord, Data, Enum, Typeable, SafeCopy)
data Status =
    Draft
  | Published
    deriving (Eq, Ord, Data, Typeable)

$(deriveSafeCopy 0 'base ''Status)
data Post = Post
    { postId  :: PostId
    , title   :: Text
    , author  :: Text
    , body    :: Text
    , date    :: UTCTime
    , status  :: Status
    , tags    :: [Text]
    }
    deriving (Eq, Ord, Data, Typeable)
-- 表示一个博客结构体的数据类型


$(deriveSafeCopy 0 'base ''Post)

-- 增加对IxSet的支持,定义用来索引的keys
-- 然后就可以在IxSet中保存数据了
newtype Title     = Title Text    deriving (Eq, Ord, Data, Typeable, SafeCopy)
newtype Author    = Author Text   deriving (Eq, Ord, Data, Typeable, SafeCopy)
newtype Tag       = Tag Text      deriving (Eq, Ord, Data, Typeable, SafeCopy)
newtype WordCount = WordCount Int deriving (Eq, Ord, Data, Typeable, SafeCopy)

instance Indexable Post where
    empty = ixSet [ ixFun $ \bp -> [ postId bp ]
                  , ixFun $ \bp -> [ Title  $ title bp  ]
                  , ixFun $ \bp -> [ Author $ author bp ]
                  , ixFun $ \bp -> [ status bp ]
                  , ixFun $ \bp -> map Tag (tags bp)
                  , ixFun $ (:[]) . date  -- point-free, just for variety
                  , ixFun $ \bp -> [ WordCount (length $ Text.words $ body bp) ]
                  ]

data Blog = Blog
    { nextPostId :: PostId
    , posts      :: IxSet Post
    }
    deriving (Data, Typeable)

$(deriveSafeCopy 0 'base ''Blog)

initialBlogState :: Blog
initialBlogState =
    Blog { nextPostId = PostId 1
         , posts      = empty
         }
-- | create a new, empty post and add it to the database
newPost :: UTCTime -> Update Blog Post
newPost pubDate =
    do b@Blog{..} <- get
       let post = Post { postId = nextPostId
                       , title  = Text.empty
                       , author = Text.empty
                       , body   = Text.empty
                       , date   = pubDate
                       , status = Draft
                       , tags   = []
                       }
       put $ b { nextPostId = succ nextPostId
               , posts      = IxSet.insert post posts
               }
       return post
-- | update the post in the database (indexed by PostId)
updatePost :: Post -> Update Blog ()
updatePost updatedPost =
    do b@Blog{..} <- get
       put $ b { posts = IxSet.updateIx (postId updatedPost) updatedPost posts
               }
postById :: PostId -> Query Blog (Maybe Post)
postById pid =
     do Blog{..} <- ask
        return $ getOne $ posts @= pid
postsByStatus :: Status -> Query Blog [Post]
postsByStatus status =
    do Blog{..} <- ask
       return $ IxSet.toDescList (Proxy :: Proxy UTCTime) $ posts @= status

$(makeAcidic ''Blog
  [ 'newPost
  , 'updatePost
  , 'postById
  , 'postsByStatus
  ])


-- | HTML template that we use to render all the pages on the site
template :: Text -> [Html] -> Html -> Response
template title headers body =
  toResponse $
    H.html $ do
      H.head $ do
        css
        H.title (H.toHtml title)
        H.meta ! A.httpEquiv "Content-Type" ! A.content "text/html;charset=utf-8"
        sequence_ headers
      H.body $ do
        H.ul ! A.id "menu" $ do
         H.li $ H.a ! A.href "/" $ "home"
         H.li $ H.a ! A.href "/drafts" $ "drafts"
         H.li $ H.form ! A.enctype "multipart/form-data"
                       ! A.method "POST"
                       ! A.action "/new" $ H.button $ "new post"
        body

-- | CSS for our site
--
-- Normally this would live in an external .css file.
-- It is included inline here to keep the example self-contained.
css :: Html
css =
    let s = Text.concat [ "body { color: #555; padding: 0; margin: 0; margin-left: 1em;}"
                        , "ul { list-style-type: none; }"
                        , "ol { list-style-type: none; }"
                        , "h1 { font-size: 1.5em; color: #555; margin: 0; }"
                        , ".author { color: #aaa; }"
                        , ".date { color: #aaa; }"
                        , ".tags { color: #aaa; }"
                        , ".post { border-bottom: 1px dotted #aaa; margin-top: 1em; }"
                        , ".bdy  { color: #555; margin-top: 1em; }"
                        , ".post-footer { margin-top: 1em; margin-bottom: 1em; }"
                        , "label { display: inline-block; width: 3em; }"
                        , "#menu { margin: 0; padding: 0; margin-left: -1em;"
                        ,         "border-bottom: 1px solid #aaa; }"
                        , "#menu li { display: inline; margin-left: 1em; }"
                        , "#menu form { display: inline; margin-left: 1em; }"
                        ]
    in H.style ! A.type_ "text/css" $ H.toHtml s

edit :: AcidState Blog -> ServerPart Response
edit acid =
    do pid   <- PostId <$> lookRead "id"
       mMsg  <- optional $ lookText "msg"
       mPost <- query' acid (PostById pid)
       case mPost of
         Nothing ->
             notFound $ template "no such post" [] $ do "Could not find a post with id "
                                                        H.toHtml (unPostId pid)
         (Just p@(Post{..})) ->
             msum [ do method GET
                       ok $ template "foo" [] $ do
                         case mMsg of
                           (Just msg) | msg == "saved" -> "Changes saved!"
                           _ -> ""
                         H.form ! A.enctype "multipart/form-data"
                              ! A.method "POST"
                              ! A.action (H.toValue $ "/edit?id=" ++
                                                      (show $ unPostId pid)) $ do
                           H.label "title" ! A.for "title"
                           H.input ! A.type_ "text"
                                   ! A.name "title"
                                   ! A.id "title"
                                   ! A.size "80"
                                   ! A.value (H.toValue title)
                           H.br
                           H.label "author" ! A.for "author"
                           H.input ! A.type_ "text"
                                   ! A.name "author"
                                   ! A.id "author"
                                   ! A.size "40"
                                   ! A.value (H.toValue author)
                           H.br
                           H.label "tags" ! A.for "tags"
                           H.input ! A.type_ "text"
                                   ! A.name "tags"
                                   ! A.id "tags"
                                   ! A.size "40"
                                   ! A.value (H.toValue $ Text.intercalate ", " tags)
                           H.br
                           H.label "body" ! A.for "body"
                           H.br
                           H.textarea ! A.cols "80" ! A.rows "20" ! A.name "body" $ H.toHtml body
                           H.br
                           H.button ! A.name "status" ! A.value "publish" $ "publish"
                           H.button ! A.name "status" ! A.value "save"    $ "save as draft"
                  , do method POST
                       ttl   <- lookText' "title"
                       athr  <- lookText' "author"
                       tgs   <- lookText' "tags"

                       bdy   <- lookText' "body"
                       now   <- liftIO $ getCurrentTime
                       stts  <- do s <- lookText' "status"
                                   case s of
                                      "save"    -> return Draft
                                      "publish" -> return Published
                                      _         -> mzero
                       let updatedPost =
                               p { title  = ttl
                                 , author = athr
                                 , body   = bdy
                                 , date   = now
                                 , status = stts
                                 , tags   = map Text.strip $ Text.splitOn "," tgs
                                 }
                       update' acid (UpdatePost updatedPost)
                       case status of
                         Published ->
                           seeOther ("/view?id=" ++ (show $ unPostId pid))
                                    (toResponse ())
                         Draft     ->
                           seeOther ("/edit?msg=saved&id=" ++ (show $ unPostId pid))
                                    (toResponse ())
                  ]

                 where lookText' = fmap toStrict . lookText
-- | create a new blog post in the database , and then redirect to /edit
new :: AcidState Blog -> ServerPart Response
new acid =
    do method POST
       now <- liftIO $ getCurrentTime
       post <- update' acid (NewPost now)
       seeOther ("/edit?id=" ++ show (unPostId $ postId post)) (toResponse ())
-- | render a single blog post into an HTML fragment
postHtml  :: Post -> Html
postHtml (Post{..}) =
  H.div ! A.class_ "post" $ do
    H.h1 $ H.toHtml title
    H.div ! A.class_ "author" $ do "author: "    >> H.toHtml author
    H.div ! A.class_ "date"   $ do "published: " >> H.toHtml (show date)
    H.div ! A.class_ "tags"   $ do "tags: "       >> H.toHtml (Text.intercalate ", " tags)
    H.div ! A.class_ "bdy" $ H.toHtml body
    H.div ! A.class_ "post-footer" $ do
     H.span $ H.a ! A.href (H.toValue $ "/view?id=" ++
                            show (unPostId postId)) $ "permalink"
     H.span $ " "
     H.span $ H.a ! A.href (H.toValue $ "/edit?id=" ++
                            show (unPostId postId)) $ "edit this post"
-- | view a single blog post
view :: AcidState Blog -> ServerPart Response
view acid =
    do pid <- PostId <$> lookRead "id"
       mPost <- query' acid (PostById pid)
       case mPost of
         Nothing ->
             notFound $ template "no such post" [] $ do "Could not find a post with id "
                                                        H.toHtml (unPostId pid)
         (Just p) ->
             ok $ template (title p) [] $ do
                 (postHtml p)
-- | render all the Published posts (ordered newest to oldest)
home :: AcidState Blog -> ServerPart Response
home acid =
    do published <- query' acid (PostsByStatus Published)
       ok $ template "home" [] $ do
         mapM_ postHtml published
-- | show a list of all unpublished blog posts
drafts :: AcidState Blog -> ServerPart Response
drafts acid =
    do drafts <- query' acid (PostsByStatus Draft)
       case drafts of
         [] -> ok $ template "drafts" [] $ "You have no unpublished posts at this time."
         _ ->
             ok $ template "home" [] $
                 H.ol $ mapM_ editDraftLink drafts
    where
      editDraftLink Post{..} =
        H.a ! A.href (H.toValue $ "/edit?id=" ++ show (unPostId postId)) $ H.toHtml title
-- | route incoming requests
route :: AcidState Blog -> ServerPart Response
route acid =
    do decodeBody (defaultBodyPolicy "/tmp/" 0 1000000 1000000)
       msum [ dir "favicon.ico" $ notFound (toResponse ())
            , dir "edit"        $ edit acid
            , dir "new"         $ new acid
            , dir "view"        $ view acid
            , dir "drafts"      $ drafts acid
            , nullDir          >> home acid
            ]
-- | start acid-state and the http server
main :: IO ()
main =
    do bracket (openLocalState initialBlogState)
               (createCheckpointAndClose >> (\ _ -> putStrLn "closing"))
               (\acid ->
                    simpleHTTP nullConf (route acid))
