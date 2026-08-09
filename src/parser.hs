module Parser (parseDocument) where
import AST



-- Seperates lines and puts each line into an array  example output : ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
splitLines :: String -> [String]
splitLines [] = []
splitLines str = firstLine str : splitLines (remainingLines str) where 
    
    remainingLines :: String -> String
    remainingLines [] =[]
    remainingLines (x:xs) 
        | x == '\n' = xs
        | otherwise = remainingLines xs

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


-- everything before the first @
parseContent :: String -> Content
parseContent str = Content (getContentString str) where
        getContentString :: String -> String 
        getContentString [] = []
        getContentString (x:xs) 
            | x == '@' = []
            | otherwise = x : getContentString xs


-- everything AFTER the first @ (the tag portion of the line, still containing further @s)
dropUntilTag :: String -> String
dropUntilTag [] = []
dropUntilTag (x:xs)
    | x == '@'  = xs
    | otherwise = dropUntilTag xs


-- wraps each already-split tag string into a Tag
parseTags :: [String] -> [Tag]
parseTags [] = []
parseTags (x:xs) = Tag x : parseTags xs


-- splits a string on every remaining @
getTags :: String -> [String]
getTags [] = []
getTags str = firstTag str : getTags (remainingTags str) where

    firstTag :: String -> String
    firstTag [] = []
    firstTag (x:xs)
        | x == '@' = []
        | otherwise = x : firstTag xs

    remainingTags :: String -> String
    remainingTags [] =[]
    remainingTags (x:xs) 
        | x == '@' = xs
        | otherwise = remainingTags xs


parseNote :: String -> Note 
parseNote str = Note (parseContent str) (parseTags (removeEmptyLines (getTags (dropUntilTag str))))

parseNotes :: [String] -> [Note]
parseNotes [] = []
parseNotes (x:xs) = parseNote x : parseNotes xs

parseDocument :: String -> Document
parseDocument documentContent = Document (parseNotes (removeEmptyLines(splitLines documentContent)))