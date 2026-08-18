
module Organizer (singleTagSorting, notesToPairs, getNotes) where
import Parser 
import AST
import qualified Data.Map as Map
import Data.Map (Map)





-- Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "Finish JML parser ") [Tag "todo"], Note (Content "What the hell is going here ") [Tag "hello",Tag "bye",Tag "and this is my life"], Note (Content "No tag here") []]

-- Input/Output Examples
-- Input:  Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
-- Output: [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
getNotes :: Document -> [Note]
getNotes (Document notes) = notes


-- Input/Output Examples
-- Input:  Note (Content "Buy milk ") [Tag "shopping"]
-- Output: Content "Buy milk "
getContent :: Note -> Content
getContent (Note content _ ) = content


-- Input/Output Examples
-- Input:  Note (Content "Buy milk ") [Tag "shopping", Tag "walmart"]
-- Output: Just (Tag "shopping")
-- Input:  Note (Content "No tag here") []
-- Output: Nothing
getTag :: Note -> Maybe Tag
getTag (Note _ []) = Nothing
getTag (Note _ (t:ts)) = Just t


-- Input/Output Examples
-- Input:  Note (Content "Buy milk ") [Tag "shopping", Tag "walmart"]
-- Output: Just [Tag "shopping", Tag "walmart"]
-- Input:  Note (Content "No tag here") []
-- Output: Nothing
getTags :: Note -> Maybe [Tag]
getTags Note _ [] = Nothing
getTags Note _ tags = Just tags



-- Input/Output Examples
-- Input:  [(Tag "shopping", [Content "Buy milk "]), (Tag "shopping", [Content "Buy eggs "]), (Tag "todo", [Content "Finish JML parser "])]
-- Output: fromList [(Tag "shopping", [Content "Buy eggs ", Content "Buy milk "]), (Tag "todo", [Content "Finish JML parser "])]
singleTagSorting :: [(Tag, [Content])] -> Map Tag [Content]
singleTagSorting [] = Map.empty
singleTagSorting listTagContentTuple = Map.fromListWith (++) listTagContentTuple
    
-- Input/Output Examples
-- Input:  [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
-- Output: [(Tag "shopping", [Content "Buy milk "]), (Tag "misc", [Content "No tag here"])]
notesToPairs :: [Note] -> [(Tag, [Content])]
notesToPairs [] = []
notesToPairs (x:xs) =
    case getTag x of 
        Nothing -> notesToPairs xs ++ [(Tag "misc", [getContent x])]
        Just t  -> (t, [getContent x]) : notesToPairs xs












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