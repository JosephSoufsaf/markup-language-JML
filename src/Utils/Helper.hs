import Data.Char (toLower)

isCharBalanced :: Int -> Char -> Char -> String -> Bool
isCharBalanced count open close [] 
    | count == 0  = True
    | otherwise   = False
isCharBalanced count open close (x:xs)
    | count < 0   = False 
    | x == open   = isCharBalanced (count + 1) open close xs
    | x == close  = isCharBalanced (count - 1) open close xs
    | otherwise   = isCharBalanced count open close xs


takeUntil :: (a -> Bool) -> [a] -> [a]
takeUntil _ [] = []
takeUntil fct (x:xs) 
    | fct x     = [x] 
    | otherwise = x : takeUntil fct xs  


dropUntil :: (a -> Bool) -> [a] -> [a]
dropUntil _ [] = []                     
dropUntil fct (x:xs)
    | fct x     = xs                   
    | otherwise = dropUntil fct xs

char :: Char -> String -> Maybe (Char, String)
char _ [] = Nothing
char character (x:xs)
    | character == x = Just (character, xs)
    | otherwise = Nothing 

string :: String -> String -> Maybe (String, String)
string word sentence = if length word > length sentence then False else string (x:xs) (y:ys)
string (x:xs) (y:ys)
    | x == y = string xs ys
    | otherwise 
