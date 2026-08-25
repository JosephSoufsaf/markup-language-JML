-- General result of Parser.hs
-- Document [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "Finish JML parser ") [Tag "todo"]]


-- Input/Output Examples
-- Input:  Document [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
-- Output: [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
getNotes :: Document -> [Note]
getNotes (Document notes) = notes


-- Input/Output Examples
-- Input:  Note (Content 0 "Buy milk ") [Tag "shopping"]
-- Output: Content 0 "Buy milk "
getContent :: Note -> Content
getContent (Note content _ ) = content


-- Input/Output Examples
-- Input:  Note (Content 0 "Buy milk ") [Tag "shopping", Tag "walmart"]
-- Output: Just (Tag "shopping")
-- Input:  Note (Content 1 "No tag here") []
-- Output: Nothing
getTag :: Note -> Maybe Tag
getTag (Note _ []) = Nothing
getTag (Note _ (t:ts)) = Just t


-- Input/Output Examples
-- Input:  Note (Content 0 "Buy milk ") [Tag "shopping", Tag "walmart"]
-- Output: Just [Tag "shopping", Tag "walmart"]
-- Input:  Note (Content 1 "No tag here") []
-- Output: Nothing
getTags :: Note -> Maybe [Tag]
getTags (Note _ []) = Nothing
getTags (Note _ tags) = Just tags


-- Input/Output Examples
-- Input:  [(Tag "shopping", [Content 0 "Buy milk "]), (Tag "shopping", [Content 3 "Buy eggs "]), (Tag "todo", [Content 1 "Finish JML parser "])]
-- Output: fromList [(Tag "shopping", [Content 3 "Buy eggs ", Content 0 "Buy milk "]), (Tag "todo", [Content 1 "Finish JML parser "])]
singleTagSorting :: [(Tag, [Content])] -> Map Tag [Content]
singleTagSorting [] = Map.empty
singleTagSorting listTagContentTuple = Map.fromListWith (++) listTagContentTuple


-- Input/Output Examples
-- Input:  [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
-- Output: [(Tag "shopping", [Content 0 "Buy milk "]), (Tag "misc", [Content 1 "No tag here"])]
notesToPairs :: [Note] -> [(Tag, [Content])]
notesToPairs [] = []
notesToPairs (x:xs) =
    case getTag x of 
        Nothing -> notesToPairs xs ++ [(Tag "misc", [getContent x])]
        Just t  -> (t, [getContent x]) : notesToPairs xs


-- Input/Output Examples
-- Input:  [(Tag "misc", [Content 1 "No tag here"]), (Tag "shopping", [Content 0 "Buy milk "])]
-- Output: [(Tag "shopping", [Content 0 "Buy milk "]), (Tag "misc", [Content 1 "No tag here"])]
sortMiscLast :: [(Tag, [Content])] -> [(Tag, [Content])]
sortMiscLast pairs = filter notMisc pairs ++ filter isMisc pairs
  where
    isMisc (Tag "misc", _) = True
    isMisc _ = False
    notMisc pair = not (isMisc pair)
  
instance Eq Content where
    (Content idx1 _) == (Content idx2 _) = idx1 == idx2

instance Ord Content where
    (Content idx1 _) <= (Content idx2 _) = idx1 <= idx2

sortChrono :: [(Tag, [Content])] -> [(Tag, [Content])]
sortChrono [] = []
sortChrono ((tag, contents):xs) = (tag, sort contents) : sortChrono xs






