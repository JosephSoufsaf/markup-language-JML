
module Parser (parseDocument) where
import AST



-- Seperates lines and puts each line into an array 
splitLines :: String -> [String]
splitLines [] = []
splitLines str = firstLine str : splitLines (remainingLines str) where 
    
    -- removes the first line of a text
    remainingLines :: String -> String
    remainingLines [] =[]
    remainingLines (x:xs) 
        | x == '\n' = xs
        | otherwise = remainingLines xs

    -- gets the first line of a text
    firstLine :: String -> String
    firstLine  [] = []
    firstLine  (x:xs) 
        | x == '\n' = []
        | otherwise = x : firstLine xs

removeEmptyLines :: [String] -> [String]
removeEmptyLines [] = []
removeEmptyLines (x:xs)
    | x == "" = removeEmptyLines xs
    | otherwise = x : removeEmptyLines xs

-- it wraps the String from getContentString into Content data type
parseContent :: String -> Content
parseContent str = Content (getContentString str) where

        -- takes a string and returns as a value everything before the @. it returns a String
        getContentString :: String -> String 
        getContentString [] = []
        getContentString (x:xs) 
            | x == '@' = []
            | otherwise = x : getContentString xs
    
-- takes a string and returns as a value everything after the @. it returns a Maybe Tag
parseTag :: String -> Maybe Tag
parseTag [] = Nothing
parseTag  (x:xs)
    | x == '@' = Just (Tag xs) 
    | otherwise = parseTag xs 

-- Just creates a Note Data type with Content and Tag if there is one
parseNote :: String  -> Note 
parseNote str = Note (parseContent str) (parseTag str)

-- Just creates a list of Notes Data type each with content or tag if there is one
parseNotes :: [String] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs 

-- Just creates a Document Data type from list of Note Data type/ Version 1 of the function
parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (removeEmptyLines(splitLines documentContent)))





















