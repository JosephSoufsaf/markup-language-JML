import Parser 
import AST
import Data.Bool (Bool(True, False))
import AST (Tag)
import Data.IntMap (insert)

--Document [Note (Content "Buy milk ") (Just (Tag "shopping")),Note (Content "Finish JML parser ") (Just (Tag "todo")),Note (Content "No tag here") Nothing]
-- Objectif right now: We want to organize the document into a tuples (Tag, [Content]) and then if we find necessary make a list of said tuples




-- a bunch of random fucking functions I dont know what I will do with but I might need cause I am not good at recursions

getNotes :: Document -> [Note]
getNotes (Document notes) = notes

getTag :: Note -> Maybe Tag
getTag (Note _ Nothing)    = Nothing       
getTag (Note _ (Just tag)) = Just tag       


getContent :: Note -> Content
getContent (Note content _ ) = content


isIn :: a -> [a] -> Bool
isIn _ [] = False
isIn element (x:xs)
    | x == element = True
    | otherwise = isIn element xs 

getTags :: [Note] -> [Maybe Tag]
getTags [] = []
getTags (x:xs) = getTag x : getTags xs


map :: (a -> b) -> [a] -> [b]
map _ [] = []
map fct (x:xs) = (fct x) : map fct xs

organizeByTag :: [Note] -> [(Tag, [Content])]
organizeByTag [] = []
organizeByTag (x:xs) = 
    case getTag x of
        Nothing  -> organizeByTag xs
        Just tag -> insertTagContent tag (getContent x) (organizeByTag xs) where 

            insertTagContent :: Tag -> Content -> [(Tag, [Content])] -> [(Tag, [Content])]
            insertTagContent tag content [] = [(tag, [content])]
            insertTagContent tag content ((t, contents) : xs)
                | t == tag  = (t, content : contents) : xs
                | otherwise = (t, contents) : insertTagContent tag content xs

                




