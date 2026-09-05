module Parser where
import AST
import qualified Data.Map as Map
import Data.List (isInfixOf)



--------------  START OF LINE SPLITTING FUNCTIONS --------------
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

-- Example Input: "#view:tree"
-- Example Output: True
-- Example Input: "Buy milk @shopping"
-- Example Output: False
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


-- Example Input: "#view:tree"
-- Example Output: "view"
getKey :: String -> String
getKey [] = []
getKey (x:xs)
    | x == '#'  = getKey xs
    | x == ':'  = []
    | otherwise = x : getKey xs

-- Example Input: "#view:tree"
-- Example Output: "tree"
getValue :: String -> String
getValue [] = []
getValue (x:xs)
    | x == ':'  = xs
    | otherwise = getValue xs

-- Example Input: ["#view:tree", "#sort:alphabetical"]
-- Example Output: "tree"
-- Example Input: []
-- Example Output: "flat"
findViewValue :: [String] -> String
findViewValue [] = "flat"
findViewValue (line:rest)
    | getKey line == "view" = getValue line
    | otherwise = findViewValue rest


-- Example Input: ["#view:tree", "#sort:alphabetical"]
-- Example Output: "alphabetical"
-- Example Input: []
-- Example Output: "alphabetical"
findSortValue :: [String] -> String
findSortValue [] = "alphabetical"
findSortValue (line:rest)
    | getKey line == "sort" = getValue line
    | otherwise = findSortValue rest

-------------- END OF HEADER FUNCTIONS --------------


-------------- START OF INDEX ASSIGNING FUNCTIONS --------------
-- Example Input: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: [(0, "Buy milk @shopping"), (1, "Finish JML parser @todo"), (2, "No tag here")]
assignIndex :: [String] -> [(Int, String)]
assignIndex lines = (zip [0..] lines)

-------------- END OF INDEX ASSIGNING FUNCTIONS --------------


-------------- START OF PARSING FUNCTIONS --------------
-- Example Input: (0, "Buy milk @shopping")
-- Example Output: Content 0 "Buy milk "

-- if it is a drawing section then I have to say its a drawing so the
-- functions know how to render it
parseContent :: (Int, String) -> Content
parseContent (index, line)
    | ("/*" `isInfixOf` line) && ("*/" `isInfixOf` line) = Drawing index (removeDelimiters (getContentString line))
    | otherwise = Content index (getContentString line) where
        getContentString :: String -> String 
        getContentString [] = []
        getContentString (x:xs) 
            | x == '@' = []
            | otherwise = x : getContentString xs



removeFirstDelimiters :: String -> String
removeFirstDelimiters [] = []
removeFirstDelimiters ('/':'*':xs) = xs
removeFirstDelimiters xs = xs

removeDelimiters :: String -> String
removeDelimiters string =
    reverse (removeFirstDelimiters (reverse (removeFirstDelimiters string)))











-- Example input:  "Buy milk @shopping@walmart"
-- Example output: "shopping@walmart"
dropUntilTag :: String -> String
dropUntilTag [] = []
dropUntilTag (x:xs)
    | x == '@'  = xs
    | otherwise = dropUntilTag xs


-- Example input:  ["shopping", "walmart"]
-- Example output: [Tag "shopping", Tag "walmart"]
parseTags :: [String] -> [Tag]
parseTags [] = []
parseTags (x:xs) = Tag x : parseTags xs


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


-- Example Input: [Tag "shopping "]
-- Example Output: [Tag "shopping"]
trimTags :: [Tag] -> [Tag]
trimTags [] = []
trimTags ((Tag name):xs) = Tag (trimEdges name) : trimTags xs


-- Example Input: "shopping "
-- Example Output: "shopping"
trimEdges :: String -> String
trimEdges str = reverse (removeEmptySpace (reverse (removeEmptySpace str))) where
    removeEmptySpace :: String -> String
    removeEmptySpace [] = []
    removeEmptySpace (c:cs)
        | c == ' '  = removeEmptySpace cs
        | otherwise = c : cs


-- Example Input: (0, "Buy milk @shopping")
-- Example output: Note (Content 0 "Buy milk ") [Tag "shopping"]
parseNote :: (Int, String) -> Note
parseNote (index, line) = Note (parseContent (index, line)) (trimTags (parseTags (removeEmptyLines (getTags (dropUntilTag line)))))


-- Example input:  [(0, "Buy milk @shopping"), (1, "No tag here")]
-- Example output: [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
parseNotes :: [(Int, String)] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs

-- Example input:  "Buy milk @shopping\nNo tag here"
-- Example output: Document [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (assignIndex (removeHeaders (removeEmptyLines (splitLines documentContent)))))

-------------- END OF PARSING FUNCTIONS --------------