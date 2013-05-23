import Debug.Hood.Observe


main = runO ex9

ex9 = print $ observe "foldl (+) 0 [1..4]" foldl (+) 0 ([1..4]::[Int])
