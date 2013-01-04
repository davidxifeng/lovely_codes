{-# LANGUAGE DeriveDataTypeable, GeneralizedNewtypeDeriving
  , OverloadedStrings, TemplateHaskell #-}
module Main where

import Control.Applicative (pure)
import Control.Category   ((.), (>>>))
--import Control.Comonad.Trans.Store.Lazy
import Data.Acid          (Update)
import Data.Data          (Data, Typeable)
import Data.IxSet         (IxSet, Indexable(empty), (@=), fromList, ixFun, ixSet)
import Data.Lens          (Lens, (^$), (^.), (^=), (^%=), (^%%=), (^+=), (%=), getL, setL, modL)
import Data.Lens.Template (makeLens)
import Data.Lens.IxSet    (ixLens)
import Data.Lens.Partial.Common (PartialLens(..), maybeLens, totalLens)
import Data.SafeCopy      (SafeCopy, base, deriveSafeCopy)
import Data.Text          (Text)
import Prelude            hiding ((.))
newtype UserId = UserId { _userInt :: Integer } 
    deriving (Eq, Ord, Data, Typeable, SafeCopy, Show)

$(makeLens ''UserId)

data Name = Name 
    { _nickName  :: Text
    , _firstName :: Text
    , _lastName  :: Text
    }
    deriving (Eq, Ord, Data, Typeable, Show)

$(deriveSafeCopy 0 'base ''Name)
$(makeLens ''Name)

data User = User
    { _userId :: UserId
    , _name   :: Name
    }
    deriving (Eq, Ord, Data, Typeable, Show)

$(deriveSafeCopy 0 'base ''User)
$(makeLens ''User)

-- | example user
stepcut :: User
stepcut = 
    User { _userId = UserId 0
         , _name   = Name { _nickName  = "stepcut"
                          , _firstName = "Jeremy"
                          , _lastName  = "Shaw"
                          }
         }
stepcutFirstName :: Text
stepcutFirstName = firstName ^$ name ^$ stepcut
stepcutFirstName2 :: Text
stepcutFirstName2 = _firstName $ _name $ stepcut
stepcutFirstName3 :: Text
stepcutFirstName3 = (stepcut ^. name) ^. firstName
getFirstName :: User -> Text
getFirstName = getL firstName . getL name 
stepcutFirstName4 :: Text
stepcutFirstName4 = firstName . name ^$ stepcut
stepcutFirstName5 :: Text
stepcutFirstName5 = _firstName . _name $ stepcut
setUserId :: (User -> User)
setUserId = userId ^= (UserId 1)
setStepcutUserId :: User
setStepcutUserId = userId ^= (UserId 1) $ stepcut
setUserId' :: (User -> User)
setUserId' = setL userId (UserId 1)
incUserId :: UserId -> UserId
incUserId = (userInt ^%= succ)
incUserId' :: UserId -> UserId
incUserId' = modL userInt succ
setNick :: Text -> (User -> User)
setNick nick = name ^%= (nickName ^= nick)
setNick2 :: Text -> (User -> User)
setNick2 newNick = (nickName . name) ^= newNick
setNick3 :: Text -> (User -> User)
setNick3 newNick = (name >>> nickName) ^= newNick
addToUserId :: Integer -> (UserId -> UserId)
addToUserId i = (userInt ^+= i)
instance Indexable User where
    empty = ixSet [ ixFun $ \u -> [ userId ^$ u ]
                  ]
data UserState = UserState 
    { _nextUserId :: UserId
    , _users      :: IxSet User
    }
    deriving (Eq, Ord, Data, Typeable, Show)

$(deriveSafeCopy 0 'base ''UserState)
$(makeLens ''UserState)

userState :: UserState
userState = 
    UserState { _nextUserId = UserId 1
              , _users      = fromList [ stepcut ]
              }

user :: (Typeable key) => key -> Lens (IxSet User) (Maybe User)
user = ixLens
user0 :: Maybe User
user0 = user (UserId 0) ^$ users ^$ userState
addUserId1 :: UserState
addUserId1 = 
    let stepcut1 = userId ^= (UserId 1) $ stepcut -- create a duplicate of the stepcut 
                                                  -- record but with 'UserId 1'
    in (users ^%= user (userId ^$ stepcut1) ^= (Just stepcut1)) userState
addUserId1' :: UserState
addUserId1' = 
    let stepcut1 = userId ^= (UserId 1) $ stepcut -- create a duplicate of the stepcut 
                                                  -- record but with 'UserId 1'
    in (users ^%= user (UserId 0) ^= (Just stepcut1)) userState
deleteUserId0 :: UserState
deleteUserId0 = (users ^%= user (UserId 0) ^= Nothing) userState
changeNick :: UserState
changeNick = (users ^%= user (UserId 0) ^%= fmap (name ^%= (nickName ^= "stepkut"))) userState
changeNick2 :: UserState
changeNick2 = ((users >>> user (UserId 0)) ^%= fmap ((name >>> nickName) ^= "stepkut")) userState
-- | note: `setPL` does not insert into an `IxSet` it only modifies a 
-- value if the key already exists in the map
ixPLens :: (Typeable key, Ord a, Typeable a, Indexable a) => key -> PartialLens (IxSet a) a
ixPLens key = maybeLens . totalLens (ixLens key)
changeNick' :: Update UserState (IxSet User)
changeNick' = users %= user (UserId 0) ^%= fmap (name ^%= (nickName ^= "stepkut"))
