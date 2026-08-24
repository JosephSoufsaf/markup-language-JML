module Parser (parseDocument, splitLines, findViewValue, findSortValue) where
import AST



--------------  START OF LINE SPLITTING FUNCTIONS --------------
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

--------------  END OF LINE SPLITTING FUNCTIONS --------------




-------------- START OF HEADER FUNCTIONS --------------
-- Example Input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
removeHeaders ::  [String] -> [String]
removeHeaders [] = []
removeHeaders (x:xs)
    | containsHeader x = removeHeaders xs
    | otherwise = x : removeHeaders xs

-- Helper functions for the header
containsHeader :: String -> Bool
containsHeader [] = False
containsHeader (x:xs)
            | x == '#' = True
            | otherwise = False 


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


findSortValue :: [String] -> String
findSortValue [] = "alphabetical"
findSortValue (line:rest)
    | getKey line == "sort" = getValue line
    | otherwise = findSortValue rest

-------------- END OF HEADER FUNCTIONS --------------


-------------- START OF INDEX ASSIGNING FUNCTIONS --------------
-- Example Input: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: [(1, "Buy milk @shopping", (2, "Finish JML parser @todo"), (3, "No tag here")]
assignIndex :: [String] -> [(Int, String)]
assignIndex lines = (zip [0..] lines)

-------------- END OF INDEX ASSIGNING FUNCTIONS --------------

    
-------------- START OF PARSING FUNCTIONS --------------

-- Example Input: (1, "Buy Milk @shopping")
-- Example Output : Content 1 "Buy Milk"
parseContent :: (Int, String) -> Content
parseContent (index, line) = Content index (getContentString line) where
    -- Example input:  (1, "Buy milk @shopping")
    -- Example output: Content 1 "Buy Milk"
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


-- Example Input: [(1, "Buy milk @shopping")]
-- Example output: Note (Content 1 "Buy milk ") [Tag "shopping"]
parseNote :: (Int, String) -> Note
parseNote (index, line) = Note (parseContent (index, line)) (trimTags (parseTags (removeEmptyLines (getTags (dropUntilTag line)))))



-- Example input:  [(1, "Buy milk @shopping"), (2, "No tag here")]
-- Example output: [Note (Content 1 "Buy milk ") [Tag "shopping"], Note (Content 2 "No tag here") []]
parseNotes :: [(Int, String)] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs

-- Example input:  "Buy milk @shopping\nNo tag here"
-- Example output: Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (assignIndex (removeHeaders (removeEmptyLines (splitLines documentContent)))))


-------------- END OF PARSING FUNCTIONS --------------