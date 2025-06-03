module Collatz where
import System.Console.Terminfo (Point(col))

-- Exercise on it: The collatz COnjecture
-- The Collatz sequence is defined by taking any number as a starting value, and then repeatedly performing the following operation:

-- if the number is even, divide it by two
-- if the number is odd, triple it and add one
-- eventually it should go to 1

-- for even and odd
step :: Integer -> Integer
step x = if even x then down else up
    where down = div x 2
          up = 3*x + 1

-- x computes the steps to reach to 1
collatz :: Integer -> Integer
collatz 1 = 0
collatz x = 1 + collatz (step x)


-- longest finds the number with the longest collatz sequence with intial values
longest :: Integer -> Integer
-- between 0 and upperbound
-- longest upperBound = longest' 0 0 upperBound
longest upperBound = longest' 0 0 upperBound

-- helper function
longest' :: Integer -> Integer -> Integer -> Integer

longest' number _ 0 = number
-- recusrion step : check if n has a longer Collatz sequence than the current known longest
longest' number maxlength n = 
    if len > maxlength
    then longest' n len (n - 1)
    else longest' number maxlength (n - 1)
    where len = collatz n
--

main :: IO ()
main = do
    print (longest 100)    -- 97 is the longest collatz sequence
    print (step 3)         -- 10
    print (collatz 3)      -- will be computed in 7 steps
    print (collatz 97)
-- 
