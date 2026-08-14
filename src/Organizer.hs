
module Organizer (organizeByTag, notesToPairs, getNotes) where
import Parser 
import AST
import qualified Data.Map as Map
import Data.Map (Map)





-- Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "Finish JML parser ") [Tag "todo"], Note (Content "What the hell is going here ") [Tag "hello",Tag "bye",Tag "and this is my life"], Note (Content "No tag here") []]


getNotes :: Document -> [Note]
getNotes (Document notes) = notes



getContent :: Note -> Content
getContent (Note content _ ) = content


getTag :: Note -> Maybe Tag
getTag (Note _ []) = Nothing
getTag (Note _ (t:ts)) = Just t

-- Organisation that lets each note have a single tag and ignores everything after the first @. The note will still have a list of tags but all of them except the first one will be ignored.
organizeByTag :: [(Tag, [Content])] -> Map Tag [Content]
organizeByTag [] = Map.empty
organizeByTag listTagContentTuple = Map.fromListWith (++) listTagContentTuple
         

notesToPairs :: [Note] -> [(Tag, [Content])]
notesToPairs [] = []
notesToPairs (x:xs) =
    case getTag x of 
        Nothing -> (Tag "misc", [getContent x]) : notesToPairs xs 
        Just t -> (t, [getContent x]) : notesToPairs xs




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