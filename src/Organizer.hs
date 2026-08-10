import Parser 
import AST
import qualified Data.Map as Map
import Data.Map (Map)
import qualified Control.Applicative as Map
import Distribution.Compat.CharParsing (CharParsing(string))



-- Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "Finish JML parser ") [Tag "todo"], Note (Content "What the hell is going here ") [Tag "hello",Tag "bye",Tag "and this is my life"], Note (Content "No tag here") []]

-- Objectif right now: We want to organize the document into a tuples ([Tag], [Content]) and then if we find necessary make a list of said tuples


-- Original content
-- Buy milk @shopping
-- Finish JML parser @todo
-- What the hell is going here @hello@bye@and this is my life
-- No tag here



-- a bunch of random fucking functions I dont know what I will do with but I might need cause I am not good at recursions

getNotes :: Document -> [Note]
getNotes (Document notes) = notes

getTag :: Note -> Maybe Tag
getTag (Note _ (t:ts)) = Just t
getTag (Note _ []) = Nothing



getContent :: Note -> Content
getContent (Note content _ ) = content

getStringFromContent :: Content -> String 
getStringFromContent Content string = string




getTags :: Note -> [Tag]
getTags (Note _ tags) = tags




organizeByTag :: [Note] -> Map Tag [Content]
organizeByTag [] = Map.empty
organizeByTag notes = Map.fromListWith (++) listTagContentTuple where

    listTagContentTuple = makeListTuple notes

    makeListTuple :: [Note] -> [(Tag, Content)]
    makeListTuple [] = []
    makeListTuple (x:xs) = (getTag x, getContent x) : makeListTuple xs





-- For practice might be useful to remember its signature.
-- map :: (a -> b) -> [a] -> [b]
-- map _ [] = []
-- map fct (x:xs) = (fct x) : map fct xs

-- For practice might be useful to remember its signature.
-- isIn :: a -> [a] -> Bool
-- isIn _ [] = False
-- isIn element (x:xs)
--     | x == element = True
--     | otherwise = isIn element xs 