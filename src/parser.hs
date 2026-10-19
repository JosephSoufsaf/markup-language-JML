module Parser where
import AST
import Data.List (isInfixOf)
import Data.String
import Data.Bifunctor (second)
import Data.Char (isSpace, isAlpha)
import Data.List (isPrefixOf)
import Data.Bifunctor (second)


--------------  START OF LINE SPLITTING FUNCTIONS --------------
-- Example input:  "#view:tree\nBuy milk @shopping\nFinish JML parser @todo\nNo tag here"
-- Example output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
splitLines :: String -> [String]
splitLines str = lines str

-- Example Input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here", "      "]
-- Example Output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
removeEmptyLines :: [String] -> [String]
removeEmptyLines = filter (not . all isSpace)

--------------  END OF LINE SPLITTING FUNCTIONS --------------



-------------- START OF HEADER FUNCTIONS --------------

isWord :: String -> Bool
isWord w = not (null w) && all isAlpha w


-- Example Input: "#view:tree"
-- Example output: True
-- This function verifies that the format of a header is valid
-- "#view:tree" is valid but so is "#chocolate:fountain" because only the format is valid
validateHeaderFormat :: String -> Bool
validateHeaderFormat ('#':rest) =
    case span isAlpha rest of
        (firstHalf, ':':restOf) -> isWord firstHalf && isWord restOf
        otherwise -> False
validateHeaderFormat _ = False 



-- Example Input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
removeHeaders :: [String] -> [String]
removeHeaders listOfString = filter (not . validateHeaderFormat) listOfString   


-- Example Input: "#view:tree", "Buy milk"
-- Example output: True, False
containsHeader :: String -> Bool
containsHeader string = elem '#' string


-- Example Input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: ["#view:tree"]
getHeaders :: [String] -> [String]
getHeaders list = filter validateHeaderFormat list 

-- Example Input : "#view:tree"
-- Example Output: ("view", "tree")
identifyHeaders :: String -> (String, String)
identifyHeaders ('#':rest) = identifyHeaders rest
identifyHeaders header = second (drop 1) (break (== ':') header)

-------------- END OF HEADER FUNCTIONS --------------




-------------- START OF INDEX ASSIGNING FUNCTIONS --------------
-- Example Input: ["Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
-- Example Output: [(0, "Buy milk @shopping"), (1, "Finish JML parser @todo"), (2, "No tag here")]
assignIndex :: [String] -> [(Int, String)]
assignIndex lignes = (zip [0..] lignes)

-------------- END OF INDEX ASSIGNING FUNCTIONS --------------


-------------- START OF PARSING FUNCTIONS --------------
takeUntil :: String -> String -> String
takeUntil _ [] = []
takeUntil d (c:cs)
  | isPrefixOf d (c:cs) = []
  | otherwise = c : takeUntil d cs



dropUntil :: String -> String -> String
dropUntil _ [] = []
dropUntil d (c:cs)
  | isPrefixOf d (c:cs) = drop (length d) (c:cs)
  | otherwise = dropUntil d cs


stringType :: String -> [StyledText]-> [StyledText]
stringType [] acc = acc  
stringType ('*':'*':rest) acc = stringType (dropUntil "**" rest) (acc ++ [Bold (takeUntil "**" rest)])
stringType ('*':rest) acc = stringType (dropUntil "*" rest) (acc ++ [Italic (takeUntil "*" rest)])
stringType s acc = stringType (dropWhile (/= '*') s) (acc ++ [Plain (takeWhile (/= '*') s)])


-- Example Input : "Hello what is going on @tag"
-- Example output : "Hello what is going"
getContentString :: String -> String 
getContentString [] = []
getContentString ('@':_) = []
getContentString (x:xs) = x : getContentString xs

-- Example Input : "Hello  what is going on @aCertainTag"
-- Example output : Content 0 [Plain Hello , Bold what , Plain is going on] P.S there is a space after hello and what
parseContent :: (Int, String) -> Content
parseContent (index, line) = Content index (stringType (getContentString line) [])

-- Example input:  "Buy milk @shopping@walmart"
-- Example output: "shopping@walmart"
dropUntilTag :: String -> String
dropUntilTag [] = []
dropUntilTag ('@':xs) = xs
dropUntilTag (_:xs) = dropUntilTag xs


-- Example input:  ["shopping", "walmart"]
-- Example output: [Tag "shopping", Tag "walmart"]
parseTags :: [String] -> [Tag]
parseTags = map Tag


-- Example input:  "shopping@walmart"
-- Example output: ["shopping", "walmart"]
getTags :: String -> [String]
getTags s = case break (== '@') s of
    (tag, [])     -> [tag]
    (tag, _:rest) -> tag : getTags rest

-- Example Input: [Tag "shopping "]
-- Example Output: [Tag "shopping"]
trimTags :: [Tag] -> [Tag]
trimTags [] = []
trimTags (Tag name : xs) = Tag (trimEdges name) : trimTags xs


-- Example Input: "shopping "
-- Example Output: "shopping"
trimEdges :: String -> String
trimEdges str =
    reverse (removeSpaces (reverse (removeSpaces str)))
  where
    removeSpaces [] = []
    removeSpaces (' ':xs) = removeSpaces xs
    removeSpaces xs = xs


-- Example Input: (0, "Buy milk @shopping")
-- Example output: Note (Content 0 "Buy milk ") [Tag "shopping"]
parseNote :: (Int, String) -> Note
parseNote (index, line) = Note (parseContent (index, line)) (trimTags (parseTags (removeEmptyLines (getTags (dropUntilTag line)))))


-- Example input:  [(0, "Buy milk @shopping"), (1, "No tag here")]
-- Example output: [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]
parseNotes :: [(Int, String)] -> [Note]
parseNotes = map parseNote

-- Example input:  "Buy milk @shopping\nNo tag here"
-- Example output: Document [Note (Content 0 "Buy milk ") [Tag "shopping"], Note (Content 1 "No tag here") []]

parseDocument :: String -> Document
parseDocument documentContent =
    Document
        (parseNotes
            (assignIndex
                (removeHeaders
                    (removeEmptyLines
                        (splitLines documentContent)))))
-------------- END OF PARSING FUNCTIONS --------------2
