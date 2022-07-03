{-# LANGUAGE GADTs #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

import Control.Monad.State
import Control.Monad.Reader
import Data.Vault as V
import Data.Maybe

data Material = Rock | Air

data WallFeature = Lever | Picture | Button deriving Show

type family Other (t :: Material) :: Material
type instance Other Air  = Rock
type instance Other Rock = Air

data Tile :: Material -> * where
    RockTile :: Tile Rock
    AirTile  :: Tile Air

data Cell mat where
    Cell
        :: Tile mat
        -> Maybe (Boundary mat n)
        -> Maybe (Boundary mat s)
        -> Maybe (Boundary mat e)
        -> Maybe (Boundary mat w)
        -> Cell mat

data Boundary (a :: Material) (b :: Material) where
    Same  :: Cell mat -> Boundary mat mat
    Diff  :: WallFeature -> Cell (Other mat) -> Boundary mat (Other mat)

type Gen = ReaderT Vault (StateT Vault IO)

type Setter a b = Maybe (Boundary a b) -> Cell a -> Cell a
type Connection b a = (Setter a b, Setter b a)

-- Boundary setters
north :: Setter a b
north n (Cell t _ s e w) = Cell t n s e w

south :: Setter a b
south s (Cell t n _ e w) = Cell t n s e w

east :: Setter a b
east e (Cell t n s _ w) = Cell t n s e w

west :: Setter a b
west w (Cell t n s e _) = Cell t n s e w


new :: Tile a -> Gen (Key (Cell a))
new t = do
    k <- liftIO $ newKey
    modify $ V.insert k $ Cell t Nothing Nothing Nothing Nothing
    return k

connectSame :: Connection a a -> Key (Cell a) -> Key (Cell a) -> Gen ()
connectSame (s2,s1) ka kb = do
    v <- ask
    let b1 = fmap Same $ V.lookup kb v
        b2 = fmap Same $ V.lookup ka v
    modify $ adjust (s1 b1) ka . adjust (s2 b2) kb

connectDiff
    :: (b ~ Other a, a ~ Other b)
    => Connection a b -> WallFeature
    -> Key (Cell a) -> Key (Cell b) -> Gen ()
connectDiff (s2, s1) wf ka kb = do
    v <- ask
    let b1 = fmap (Diff wf) $ V.lookup kb v
        b2 = fmap (Diff wf) $ V.lookup ka v
    modify $ adjust (s1 b1) ka . adjust (s2 b2) kb

startFrom :: Key (Cell a) -> Gen (Cell a)
startFrom k = fmap (fromJust . V.lookup k) ask

runGen :: Gen a -> IO a
runGen g = fmap fst $ mfix $ \(~(_, v)) -> runStateT (runReaderT g v) V.empty

testMap :: Gen (Cell Rock)
testMap = do
    nw <- new RockTile
    ne <- new AirTile
    se <- new AirTile
    sw <- new AirTile

    connectDiff (west,east) Lever nw ne
    connectSame (north,south) ne se
    connectSame (east,west) se sw
    connectDiff (south,north) Button sw nw

    startFrom nw

main :: IO ()
main = do
    c <- runGen testMap
    print c


-- Show Instances

instance Show (Cell mat) where
    show (Cell t n s e w)
        = unwords ["Cell", show t, show n, show s, show e, show w]

instance Show (Boundary a b) where
    show (Same _) = "<Same>"
    show (Diff wf _) = "<Diff with " ++ show wf ++ ">"

instance Show (Tile mat) where
    show RockTile = "RockTile"
    show AirTile = "AirTile"
