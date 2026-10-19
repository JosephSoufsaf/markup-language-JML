module Organizer where

import AST
import qualified Data.Map as Map
import Data.Map (Map)
import Data.List (sort)

--------------  START OF ACCESSOR FUNCTIONS --------------

-- Extracts the list of notes from a document.
-- Example Input : Document [Note (Content 0 [Plain "Buy milk"]) [Tag "shopping"]]
-- Example Output: [Note (Content 0 [Plain "Buy milk"]) [Tag "shopping"]]
getNotes :: Document -> [Note]
getNotes (Document notes) = notes


-- Extracts the content part of a note, ignoring its tags.
-- Example Input : Note (Content 0 [Plain "Buy milk"]) [Tag "shopping"]
-- Example Output: Content 0 [Plain "Buy milk"]
getContent :: Note -> Content
getContent (Note content _) = content


-- Returns the FIRST tag of a note, or Nothing if the note has no tags.
-- Only the first tag is used to file a note, so a note tagged
-- "@shopping@walmart" is filed under "shopping" only.
-- Example Input : Note (Content 0 [Plain "Buy milk"]) [Tag "shopping", Tag "walmart"]
-- Example Output: Just (Tag "shopping")
-- Example Input : Note (Content 1 [Plain "No tag here"]) []
-- Example Output: Nothing
getTag :: Note -> Maybe Tag
getTag (Note _ [])    = Nothing
getTag (Note _ (t:_)) = Just t


-- Returns ALL the tags of a note, or Nothing if the note has none.
-- (Not used yet. Note that Parser.hs also defines a getTags with a
-- different type, so importing both modules together will be ambiguous.)
-- Example Input : Note (Content 0 [Plain "Buy milk"]) [Tag "shopping", Tag "walmart"]
-- Example Output: Just [Tag "shopping", Tag "walmart"]
getTags :: Note -> Maybe [Tag]
getTags (Note _ [])   = Nothing
getTags (Note _ tags) = Just tags

--------------  END OF ACCESSOR FUNCTIONS --------------



--------------  START OF GROUPING FUNCTIONS --------------

-- Turns each note into a (title, contents) pair.
-- The title is the note's first tag, or Tag "misc" if it has none.
-- The content is wrapped in a list so pairs can be merged with (++) later.
-- The result is a plain list: the same tag can appear several times,
-- and the notes stay in document order.
-- Example Input : [ Note (Content 0 [Plain "Buy milk"]) [Tag "shopping"]
--                 , Note (Content 1 [Plain "No tag here"]) []
--                 , Note (Content 2 [Plain "Get eggs"]) [Tag "shopping"] ]
-- Example Output: [ (Tag "shopping", [Content 0 [Plain "Buy milk"]])
--                 , (Tag "misc",     [Content 1 [Plain "No tag here"]])
--                 , (Tag "shopping", [Content 2 [Plain "Get eggs"]]) ]
notesToPairs :: [Note] -> [(Tag, [Content])]
notesToPairs [] = []
notesToPairs (note:notes) =
    case getTag note of
        Nothing  -> (Tag "misc", [getContent note]) : notesToPairs notes
        Just tag -> (tag, [getContent note]) : notesToPairs notes


-- Builds the dictionary: each tag becomes ONE key, and the contents of
-- all pairs sharing that tag are merged into one list with (++).
-- Careful: fromListWith applies the function as (new ++ old), so the
-- contents of each tag come out in REVERSE document order.
-- Example Input : [ (Tag "shopping", [c0]), (Tag "misc", [c1]), (Tag "shopping", [c2]) ]
-- Example Output: fromList [ (Tag "misc", [c1]), (Tag "shopping", [c2, c0]) ]
groupByFirstTag :: [(Tag, [Content])] -> Map Tag [Content]
groupByFirstTag = Map.fromListWith (++)


-- Restores document order inside each tag. This works because the Ord
-- instance of Content compares notes by their index.
-- Example Input : fromList [ (Tag "shopping", [c2, c0]) ]
-- Example Output: fromList [ (Tag "shopping", [c0, c2]) ]
sortContents :: Map Tag [Content] -> Map Tag [Content]
sortContents = Map.map sort


-- Moves the "misc" group to the end of a list of pairs, keeping the
-- relative order of everything else. It works on a LIST, not a Map,
-- because a Map is always ordered by key. Use it on (Map.toList m).
-- Example Input : [ (Tag "misc", [c1]), (Tag "shopping", [c0]) ]
-- Example Output: [ (Tag "shopping", [c0]), (Tag "misc", [c1]) ]
sortMiscLast :: [(Tag, [Content])] -> [(Tag, [Content])]
sortMiscLast pairs = filter (not . isMisc) pairs ++ filter isMisc pairs
  where
    -- True for the pair whose title is "misc"
    isMisc (Tag "misc", _) = True
    isMisc _               = False

--------------  END OF GROUPING FUNCTIONS --------------
