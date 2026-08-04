import Text.Read (Lexeme(String))
import Language.Haskell.TH (Type(ConT), parS)
data Note = Note Content (Maybe Tag)
data Content = Content String
data Tag = Tag String


    

getContentString :: String -> String 
getContentString (x:xs) 
    | x == '@' = []
    | otherwise = x : getContentString xs


wrapContentString :: String -> Content
wrapContentString str = Content (getContentString str)


parseTag :: String -> Maybe Tag
parseTag [] = Nothing
parseTag  (x:xs)
    | x == '@' = Just (Tag xs) 
    | otherwise = parseTag xs 



parseNote :: String  -> Note 
parseNote str = Note (wrapContentString str) (parseTag str)







