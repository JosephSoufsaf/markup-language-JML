module Parser (parseDocument, splitLines, getHeaders, findViewValue, findSortValue) where
import AST



-- Seperates lines and puts each line into an array
-- Example input:  "#view:tree\nBuy milk @shopping\nFinish JML parser @todo\nNo tag here"
-- Example output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
splitLines :: String -> [String]
splitLines [] = []
splitLines str = firstLine str : splitLines (remainingLines str) where 
    
    -- Example input: "Buy milk @shopping\nFinish JML parser @todo" 
    -- Example output: "Finish JML parser @todo"
    remainingLines :: String -> String
    remainingLines [] =[]
    remainingLines (x:xs) 
        | x == '\n' = xs
        | otherwise = remainingLines xs

    -- Example input: "Buy milk @shopping\nFinish JML parser @todo"
    -- Example output: "Buy milk @shopping"
    firstLine :: String -> String
    firstLine  [] = []
    firstLine  (x:xs) 
        | x == '\n' = []
        | otherwise = x : firstLine xs


-- Example input:  ["Buy milk @shopping", "", "No tag here", ""]
-- Example output: ["Buy milk @shopping", "No tag here"]
removeEmptyLines :: [String] -> [String]
removeEmptyLines [] = []
removeEmptyLines (x:xs)
    | x == "" = removeEmptyLines xs
    | otherwise = x : removeEmptyLines xs

removeHeaders ::  [String] -> [String]
removeHeaders [] = []
removeHeaders (x:xs)
    | containsHeader x = removeHeaders xs
    | otherwise = x : removeHeaders xs

containsHeader :: String -> Bool
containsHeader [] = False
containsHeader (x:xs)
            | x == '#' = True
            | otherwise = False 


getHeaders :: [String] -> [String]
getHeaders [] = []
getHeaders (x:xs)
    | containsHeader x = x : getHeaders xs
    | otherwise = getHeaders xs


getKey :: String -> String
getKey [] = []
getKey (x:xs)
    | x == '#'  = getKey xs
    | x == ':'  = []
    | otherwise = x : getKey xs

getValue :: String -> String
getValue [] = []
getValue (x:xs)
    | x == ':'  = xs
    | otherwise = getValue xs

findViewValue :: [String] -> String
findViewValue [] = "flat"
findViewValue (line:rest)
    | getKey line == "view" = getValue line
    | otherwise = findViewValue rest


<<<<<<< HEAD
findSortValue :: [String] -> String
findSortValue [] = "alphabetical"
findSortValue (line:rest)
    | getKey line == "sort" = getValue line
    | otherwise             = findSortValue rest



    

=======
>>>>>>> Tree-Chronological-sorting
-- everything before the first @
-- Example input:  "Buy milk @shopping"
-- Example output: Content "Buy milk "
parseContent :: String -> Content  
parseContent str = Content (getContentString str) where
        -- Example input:  "Buy milk @shopping"
        -- Example output: "Buy milk "
        getContentString :: String -> String 
        getContentString [] = []
        getContentString (x:xs) 
            | x == '@' = []
            | otherwise = x : getContentString xs


-- everything AFTER the first @
-- Example input:  "Buy milk @shopping@walmart"
-- Example output: "shopping@walmart"
dropUntilTag :: String -> String
dropUntilTag [] = []
dropUntilTag (x:xs)
    | x == '@'  = xs
    | otherwise = dropUntilTag xs


-- wraps each already-split tag string into a Tag
-- Example input:  ["shopping", "walmart"]
-- Example output: [Tag "shopping", Tag "walmart"]
parseTags :: [String] -> [Tag]
parseTags [] = []
parseTags (x:xs) = Tag x : parseTags xs







-- getTags and parseTags work together
-- splits a string on every remaining @
-- Example input:  "shopping@walmart"
-- Example output: ["shopping", "walmart"]
getTags :: String -> [String]
getTags [] = []
getTags str = firstTag str : getTags (remainingTags str) where

    -- Example input:  "shopping@walmart"
    -- Example output: "shopping"
    firstTag :: String -> String
    firstTag [] = []
    firstTag (x:xs)
        | x == '@' = []
        | otherwise = x : firstTag xs

    -- Example input:  "shopping@walmart"
    -- Example output: "walmart"
    remainingTags :: String -> String
    remainingTags [] =[]
    remainingTags (x:xs) 
        | x == '@' = xs
        | otherwise = remainingTags xs


trimTags :: [Tag] -> [Tag]
trimTags [] = []
trimTags ((Tag name):xs) = Tag (trimEdges name) : trimTags xs


trimEdges :: String -> String
trimEdges str = reverse (removeEmptySpace (reverse (removeEmptySpace str))) where
    removeEmptySpace :: String -> String
    removeEmptySpace [] = []
    removeEmptySpace (c:cs)
        | c == ' '  = removeEmptySpace cs
        | otherwise = c : cs


-- Example input:  "Buy milk @shopping@walmart"
-- Example output: Note (Content "Buy milk ") [Tag "shopping", Tag "walmart"]
parseNote :: String -> Note 
parseNote str = Note (parseContent str) (trimTags (parseTags (removeEmptyLines (getTags (dropUntilTag str)))))


-- Example input:  ["Buy milk @shopping", "No tag here"]
-- Example output: [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
parseNotes :: [String] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs

-- Example input:  "Buy milk @shopping\nNo tag here"
-- Example output: Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (removeHeaders (removeEmptyLines (splitLines documentContent))))
