module Main where

main :: IO ()
main = putStrLn "Hello, Haskell!"

-- The word ‘haskel’ means wisdom in Hebrew, 
-- but the name of the Haskell programming language comes from the logician Haskell Curry. 
-- The name Haskell comes from the Old Norse words áss (god) and ketill (helmet).
-- Haskell is
-- Functional : everything is function and uses recursion
-- Pure - Side effects mean things like reading a file, printing out text, or changing global variables. All inputs to a function must be in its arguments, and all outputs from a function in its return value.
-- Lazy - values are evaluated when they are needed
-- Strongly Typed - every Haskell value and expression has a type. 
-- Type Inferred - The compiler deduce the types of most programs
-- Garbage-Collected - has automatic memory management via garabage collection
-- Compiled - Haskell programs can be compiled to very efficient binaries, and the GHC compiler is very good at optimising functional code into performant machine code.

-- Some Features of Haskell
    -- HOF - functions can take functions as arguments
    -- Anonymous Function using lambda
    -- Partial Application
    -- Pattern Matching - just like polymorphism

-- Parentheses can be used to group expressions (just like in math and other languages).
-- Haskell	Python, Java or C
-- g h f 1	    g(h,f,1)
--- g h (f 1)	g(h,f(1))
-- g (h f 1)	g(h(f,1))
-- g (h (f 1))	g(h(f(1)))
--

-- # Python
-- price = 1 if product == "milk" else 2
price :: String -> Int
price product = if product == "milk" then 1 else 2

-- One oddity of Haskell is that the not-equals operator is written /= instead of the usual !=:
-- eg 2 != 3 is the same as 2 /= 3
-- 7 `div` 2 will give 3

-- local definitions in haskell
-- use either where or let...in
circleArea :: Double -> Double
circleArea r = pi * rsquare
    where
        pi = 3.1415926
        rsquare = r * r 
areaOfCircle :: Double -> Double
areaOfCircle r = pi * rsquare
    where
        pi = 3.1415926
        rsquare = r * r 
-- patten matching : a function can consist of multiple equations
greet :: String -> String -> String
greet "Finland" name = "Hei, " ++ name
greet "Italy" name = "Ciao, " ++ name
greet "England" name = "How do you do, " ++ name
greet _ name = "Hello, " ++ name -- the default one
-- greet "Finland" "Pekka"
-- "Hei, Pekka"

-- show 3 : found in stlib that change anythign into string
--  "3"

describe :: Integer -> String
describe 0 = "zero"
describe 1 = "one"
describe 2 = "an even prime"
describe n = "the number" ++ show n
-- describe 7
-- "the number 7"

-- In haskell all sort of loops are implemented using recursion
-- recursion
factorial :: Int -> Int
factorial 1 = 1
factorial n = n * factorial (n - 1)

-- fibonacci sequence slower version
fibonacci 1 = 1
fibonacci 2 = 1
fibonacci n = fibonacci (n - 2) + fibonacci (n - 1)

--
