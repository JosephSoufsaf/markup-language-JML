module Organizer where

import AST
import qualified Data.Map as Map
import Data.Map (Map)
import Data.List (sort)

getNotes :: Document -> [Note]
getNotes (Document notes) = notes


getContent :: Note -> Content
getContent (Note content _) = content


getTag :: Note -> Maybe Tag
getTag (Note _ [])    = Nothing
getTag (Note _ (t:_)) = Just t


getTags :: Note -> Maybe [Tag]
getTags (Note _ [])   = Nothing
getTags (Note _ tags) = Just tags


singleTagSorting :: [(Tag, [Content])] -> Map Tag [Content]
singleTagSorting = Map.fromListWith (++)


notesToPairs :: [Note] -> [(Tag, [Content])]
notesToPairs [] = []
notesToPairs (note:notes) =
    case getTag note of
        Nothing -> (Tag "misc", [getContent note]) : notesToPairs notes
        Just tag -> (tag, [getContent note]) : notesToPairs notes


sortMiscLast :: [(Tag, [Content])] -> [(Tag, [Content])]
sortMiscLast pairs = filter (not . isMisc) pairs ++ filter isMisc pairs
  where
    isMisc (Tag "misc", _) = True
    isMisc _ = False