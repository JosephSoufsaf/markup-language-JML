module Utils.Helper where


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
    | fct x     = []
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
string [] ys = Just ([], ys)
string _ [] = Nothing
string (x:xs) (y:ys)
    | x == y = case string xs ys of
                Nothing -> Nothing
                Just (matched, rest) -> Just (x:matched, rest)
    | otherwise = Nothing

satisfy :: (Char -> Bool) -> String -> Maybe (Char, String)
satisfy _ [] = Nothing
satisfy fct (x:xs)
    | fct x = Just (x, xs)
    | otherwise = Nothing


oneOf :: [Char] -> String -> Maybe (Char, String)
oneOf cs input = satisfy isAllowed input where
    isAllowed :: Char -> Bool
    isAllowed c = c `elem` cs

noneOf :: [Char] -> String -> Maybe (Char, String)
noneOf cs input = satisfy isForbidden input where
    isForbidden :: Char -> Bool
    isForbidden c = c `notElem` cs


anyChar :: String -> Maybe (Char, String)
anyChar input = satisfy isAny input where
    isAny :: Char -> Bool
    isAny _ = True


digit :: String -> Maybe (Char, String)
digit input = satisfy isDigit input where
    isDigit :: Char -> Bool
    isDigit c = c >= '0' && c <= '9'


eof :: String -> Maybe ((), String)
eof "" = Just ((), "")
eof _ = Nothing


isNameChar :: Char -> Bool
isNameChar c = isAlphaNum c || c == '_'

