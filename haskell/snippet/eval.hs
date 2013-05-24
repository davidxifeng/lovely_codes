module Eval (Token(..), Expression, eval)
where

import Data.Char ( isSpace
                 )

import Text.Parsec ( ParseError, parse, many, many1, spaces
                   , digit, char, eof, (<|>)
                   )
import Text.Parsec.String (Parser)
-- Tue Apr  9 17:59:02 CST 2013 进行优先级比较的表达式求值函数
-- Fri May 24 14:02:35 CST 2013 学习了Parsec库的使用,写了一个简单的解析器

-- possibleSpace :: Parser ()
-- possibleSpace = skipMany (satisfy isSpace)
-- 库已经定义了spaces

data Token = Plus | Minus | Times | Divided_By | Power | Number !Double
     deriving Show

type Expression = [Token]

op :: Char -> Parser Token
op p = do
        char p
        spaces
        return $ fp p
    where
        fp '-' = Minus
        fp '+' = Plus
        fp '*' = Times
        fp '/' = Divided_By
        fp '^' = Power -- 如果使用**表示power就需要look ahead了

parse_number :: Parser Token
parse_number = do
        ds <- many1 digit
        spaces
        return $ Number (read ds :: Double)

expr :: Parser Token
expr =
        op '+'
        <|>
        op '-'
        <|>
        op '*'
        <|>
        op '/'
        <|>
        op '^'
        <|>
        parse_number

exprs :: Parser [Token]
exprs = do
        r <- many expr
        eof
        return r

op_bp :: Token -> Int
op_bp op =
        case op of
            Plus       -> 1
            Minus      -> 1
            Times      -> 2
            Divided_By -> 2
            Power      -> 3
            otherwise  -> error "error input"

eval' :: Expression -> Expression
eval' [] = []
eval' (c:[]) = [c]
eval' (x:op:y:[]) =
        case op of
            Plus       -> x:op:y:[]
            Minus      -> x:op:y:[]
            Times      -> [cal op x y]
            Divided_By -> [cal op x y]
            Power      -> [cal op x y]

eval' (x:op:y:next_op:z:cs) =
        if (op_bp op) >= (op_bp next_op)
            then eval' $ (cal op x y) : next_op: z : cs
            else eval' (x : op: (eval' $ y:next_op:z : cs))

cal' :: Expression -> Token
cal' (x:op:y:[]) = cal op x y
cal' (x:[]) = x

cal :: Token -> Token -> Token -> Token
cal op (Number x) (Number y) =
        case op of
            Plus       -> Number $ x + y
            Minus      -> Number $ x - y
            Times      -> Number $ x * y
            Divided_By -> Number $ x / y
            Power      -> Number $ x ** y

eval :: String -> Double
eval s =
        let
            Number r = either (\_ -> Number 0) (cal' . eval')
                (parse exprs "Expression Parser 0.1" s)
        in
            r

test = eval "12 + 2 *3 /4 +5^2 "
test' = 12 + 2 *3 /4 +5**2
