SUDOKU IN HASKELL
Graham Hutton, January 2010
Based upon notes by Richard Bird
Slightly modifed to make it into a module and to correct 
  the example using packing and unpacking.

The program developed in this note is a good example of what
has been termed "wholemeal programming", the idea of focusing
on entire data structures rather than on their elements.  This
approach naturally leads to a compositional style, and relies
on lazy evaluation for efficiency.  Our development proceeds
by starting with a simple but impractical program, which is
then refined in a series of steps, ending up with a program
that can solve any newspaper Sudoku puzzle in an instant. 


Library file
-------------

We use a few things from the list library:

> import Data.List


Basic declarations
------------------

We begin with some basic declarations, using the terminology of
sudoku.org.uk.  Although the declarations do not enforce it,
we will only consider non-empty square matrices with a multiple
of boxsize (defined in the next section) rows.  This assumption
is important for various properties that we rely on.

> type Grid             = Matrix Value
>
> type Matrix a         = [Row a]
>
> type Row a            = [a]
>
> type Value            = Char


Basic definitions 
-----------------

> boxsize               :: Int
> boxsize               =  3
>
> values                :: [Value]
> values                =  ['1'..'9']
>
> empty                 :: Value -> Bool
> empty                 =  (== '.')
>
> single                :: [a] -> Bool
> single [_]            =  True
> single _              =  False


Example grids
-------------

Solvable only using the basic rules:

> easy                  :: Grid
> easy                  =  ["2....1.38",
>                           "........5",
>                           ".7...6...",
>                           ".......13",
>                           ".981..257",
>                           "31....8..",
>                           "9..8...2.",
>                           ".5..69784",
>                           "4..25...."]

First gentle example from sudoku.org.uk:

> gentle                :: Grid
> gentle                =  [".1.42...5",
>                           "..2.71.39",
>                           ".......4.",
>                           "2.71....6",
>                           "....4....",
>                           "6....74.3",
>                           ".7.......",
>                           "12.73.5..",
>                           "3...82.7."]

First diabolical example:

> diabolical            :: Grid
> diabolical            =  [".9.7..86.",
>                           ".31..5.2.",
>                           "8.6......",
>                           "..7.5...6",
>                           "...3.7...",
>                           "5...1.7..",
>                           "......1.9",
>                           ".2.6..35.",
>                           ".54..8.7."]

First "unsolvable" (requires backtracking) example:

> unsolvable            :: Grid
> unsolvable            =  ["1..9.7..3",
>                           ".8.....7.",
>                           "..9...6..",
>                           "..72.94..",
>                           "41.....95",
>                           "..85.43..",
>                           "..3...7..",
>                           ".5.....4.",
>                           "2..8.6..9"]

Minimal sized grid (17 values) with a unique solution:

> minimal               :: Grid
> minimal               =  [".98......",
>                           "....7....",
>                           "....15...",
>                           "1........",
>                           "...2....9",
>                           "...9.6.82",
>                           ".......3.",
>                           "5.1......",
>                           "...4...2."]

Empty grid:

> blank                 :: Grid
> blank                 =  replicate n (replicate n '.')
>                          where n = boxsize ^ 2


Extracting rows, columns and boxes
----------------------------------

Extracting rows is trivial:

> rows                  :: Matrix a -> [Row a]
> rows                  =  id

We also have, trivially, that rows . rows = id.  This property (and
similarly for cols and boxs) will be important later on.

Extracting columns is just matrix transposition:

> cols                  :: Matrix a -> [Row a]
> cols                  =  transpose

Example: cols [[1,2],[3,4]] = [[1,3],[2,4]].  Exercise: define
transpose, without looking at the library definition.

We also have that cols . cols = id.

Extracting boxes is more complicated:

> boxs                  :: Matrix a -> [Row a]
> boxs                  =  unpack . map cols . pack
>                          where
>                             pack   = split . map split
>                             split  = chop boxsize
>                             unpack = map concat . concat
>
> chop                  :: Int -> [a] -> [[a]]
> chop n []             =  []
> chop n xs             =  take n xs : chop n (drop n xs)

Example: if boxsize = 2, then we have 

   [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]

                          |
                         pack
                          |
                          v

   [[[[1,2],[3,4]],[[5,6],[7,8]]],[[[9,10],[11,12]],[[13,14],[15,16]]]]

                          |
                       map cols
                          |
                          v

   [[[[1,2],[5,6]],[[3,4],[7,8]]],[[[9,10],[13,14]],[[11,12],[15,16]]]]

                          | 
                        unpack
                          |
                          v

   [[1,2,5,6],[3,4,7,8],[9,10,13,14],[11,12,15,16]]

Note that concat . split = id, and moreover, boxs . boxs = id.


Validity checking
-----------------

Now let us turn our attention from matrices to Sudoku grids.  A grid
is valid if there are no duplicates in any row, column or box:

> valid                 :: Grid -> Bool
> valid g               =  all nodups (rows g) &&
>                          all nodups (cols g) &&
>                          all nodups (boxs g)
>
> nodups                :: Eq a => [a] -> Bool
> nodups []             =  True
> nodups (x:xs)         =  not (elem x xs) && nodups xs


A basic solver
--------------

The function choices replaces blank squares in a grid by all possible
values for that square, giving a matrix of choices:

> type Choices          =  [Value]
>
> choices               :: Grid -> Matrix Choices
> choices               =  map (map choice)
>                          where
>                             choice v = if empty v then values else [v]

Reducing a matrix of choices to a choice of matrices can be defined 
in terms of the normal cartesian product of a list of lists, which
generalises the cartesian product of two lists:

> cp                    :: [[a]] -> [[a]]
> cp []                 =  [[]]
> cp (xs:xss)           =  [y:ys | y <- xs, ys <- cp xss]

For example, cp [[1,2],[3,4],[5,6]] gives:

   [[1,3,5],[1,3,6],[1,4,5],[1,4,6],[2,3,5],[2,3,6],[2,4,5],[2,4,6]]

It is now simple to collapse a matrix of choices:

> collapse              :: Matrix [a] -> [Matrix a]
> collapse              =  cp . map cp

Finally, we can now specify a suduku solver:

> solve                 :: Grid -> [Grid]
> solve                 =  filter valid . collapse . choices

For the easy example grid, there are 51 empty squares, which means
that this function will consider 9^51 possible grids, which is:

   4638397686588101979328150167890591454318967698009

Searching this space isn't feasible; we need to think further.


Pruning the search space
------------------------

Our first step to making things better is to introduce the idea
of "pruning" the choices that are considered for each square.
Prunes go well with wholemeal programming!  In particular, from
the set of all possible choices for each square, we can prune
out any choices that already occur as single entries in the
associated row, column, and box, as otherwise the resulting
grid will be invalid.  Here is the code for this:

> prune                 :: Matrix Choices -> Matrix Choices
> prune                 =  pruneBy boxs . pruneBy cols . pruneBy rows
>                          where pruneBy f = f . map reduce . f
>
> reduce                :: Row Choices -> Row Choices
> reduce xss            =  [xs `minus` singles | xs <- xss]
>                          where singles = concat (filter single xss)
>
> minus                 :: Choices -> Choices -> Choices
> xs `minus` ys         =  if single xs then xs else xs \\ ys

Note that pruneBy relies on the fact that rows . rows = id, and
similarly for the functions cols and boxs, in order to decompose
a matrix into its rows, operate upon the rows in some way, and
then reconstruct the matrix.  Now we can write a new solver:

> solve2                :: Grid -> [Grid]
> solve2                =  filter valid . collapse . prune . choices

For example, for the easy grid, pruning leaves an average of around
2.4 choices for each of the 81 squares, or 1027134771639091200000000
possible grids.  A much smaller number, but still not feasible.


Repeatedly pruning
------------------

After pruning, there may now be new single entries, for which pruning
again may further reduce the search space.  More generally, we can 
iterate the pruning process until this has no further effect, which
in mathematical terms means that we have found a "fixpoint".  The
simplest Sudoku puzzles can be solved in this way.

> solve3                :: Grid -> [Grid]
> solve3                =  filter valid . collapse . fix prune . choices
>
> fix                   :: Eq a => (a -> a) -> a -> a
> fix f x               =  if x == x' then x else fix f x'
>                          where x' = f x

For example, for our easy grid, the pruning process leaves precisely
one choice for each square, and solve3 terminates immediately.  However,
for the gentle grid we still get around 2.8 choices for each square, or
154070215745863680000000000000 possible grids.

Back to the drawing board...


Properties of matrices
----------------------

In this section we introduce a number of properties that may hold of
a matrix of choices.  First of all, let us say that such a matrix is
"complete" if each square contains a single choice:

> complete              :: Matrix Choices -> Bool
> complete              =  all (all single)

Similarly, a matrix is "void" if some square contains no choices:

> void                  :: Matrix Choices -> Bool
> void                  =  any (any null)

In turn, we use the term "safe" for matrix for which all rows,
columns and boxes are consistent, in the sense that they do not
contain more than one occurrence of the same single choice:

> safe                  :: Matrix Choices -> Bool
> safe cm               =  all consistent (rows cm) &&
>                          all consistent (cols cm) &&
>                          all consistent (boxs cm)
>
> consistent            :: Row Choices -> Bool
> consistent            =  nodups . concat . filter single

Finally, a matrix is "blocked" if it is void or unsafe:

> blocked               :: Matrix Choices -> Bool
> blocked m             =  void m || not (safe m)


Making choices one at a time
----------------------------

Clearly, a blocked matrix cannot lead to a solution.  However, our
previous solver does not take account of this.  More importantly,
a choice that leads to a blocked matrix can be duplicated many
times by the collapse function, because this function simply
considers all possible combinations of choices.  This is the 
primary source of inefficiency in our previous solver.

This problem can be addressed by expanding choices one square at
a time, and filtering out any resulting matrices that are blocked
before considering any further choices.  Implementing this idea
is straightforward, and gives our final Sudoku solver:

> solve4                :: Grid -> [Grid]
> solve4                =  search . prune . choices
>
> search                :: Matrix Choices -> [Grid]
> search m
>  | blocked m          =  []
>  | complete m         =  collapse m
>  | otherwise          =  [g | m' <- expand m
>                             , g  <- search (prune m')]

The function expand behaves in the same way as collapse, except that
it only collapses the first square with more than one choice:

> expand                :: Matrix Choices -> [Matrix Choices]
> expand m              =
>    [rows1 ++ [row1 ++ [c] : row2] ++ rows2 | c <- cs]
>    where
>       (rows1,row:rows2) = break (any (not . single)) m
>       (row1,cs:row2)    = break (not . single) row

Note that there is no longer any need to check for valid grids at 
the end, because the process by which solutions are constructed 
guarantees that this will always be the case.  There also doesn't
seem to be any benefit in using "fix prune" rather than "prune"
above; the program is faster without using fix.  In fact, our
program now solves any newspaper Sudoku puzzle in an instant!

Exercise: modify the expand function to collapse a square with the
smallest number of choices greater than one, and see what effect 
this change has on the performance of the solver.


Testing
-------

> main                  :: IO ()
> main                  =  putStrLn (unlines (head (solve4 blank)))
