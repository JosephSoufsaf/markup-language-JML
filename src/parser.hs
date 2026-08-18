module Parser (parseDocument) where
import AST



-- Seperates lines and puts each line into an array
-- Example input:  "Buy milk @shopping\nFinish JML parser @todo\nNo tag here"
-- Example output: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
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


-- Example input:  "Buy milk @shopping@walmart"
-- Example output: Note (Content "Buy milk ") [Tag "shopping", Tag "walmart"]
parseNote :: String -> Note 
parseNote str = Note (parseContent str) (parseTags (removeEmptyLines (getTags (dropUntilTag str))))




-- Example input:  ["Buy milk @shopping", "No tag here"]
-- Example output: [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
parseNotes :: [String] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs

-- Example input:  "Buy milk @shopping\nNo tag here"
-- Example output: Document [Note (Content "Buy milk ") [Tag "shopping"], Note (Content "No tag here") []]
parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (removeEmptyLines(splitLines documentContent)))