import Text.Read (Lexeme(String))
import Language.Haskell.TH (Type(ConT), parS)
data Note = Note Content (Maybe Tag)
data Content = Content String
data Tag = Tag String


    

parseContentString :: String -> String 
parseContentString (x:xs) 
    | x == '@' = []
    | otherwise = x : parseContentString xs


parseContent :: String -> Content
parseContent str = Content (parseContentString str)


parseTag :: String -> Maybe Tag
parseTag [] = Nothing
parseTag  (x:xs)
    | x == '@' = Just (Tag xs) 
    | otherwise = parseTag xs 



parseNote :: String  -> Note 
parseNote str = Note (parseContent str) (parseTag str)







