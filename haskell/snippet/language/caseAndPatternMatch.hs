
data Test = A Int
          | B Float
          deriving (Show)

testToInt = (\x -> case x of
            (A i) -> i
            (B f ) -> ceiling f)

testToInt' = (\x -> case x of (A i) -> i; (B f ) -> ceiling f)
