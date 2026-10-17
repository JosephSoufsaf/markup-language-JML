module Parser where
import AST
import qualified Data.Map as Map
import Data.List (isInfixOf)
import Data.String
import Data.Bifunctor (second)


--------------  START OF LINE SPLITTING FUNCTIONS --------------
-- Example input:  "#view:tree\nBuy milk @shopping\nFinish JML parser @todo\nNo tag here"
-- Example output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
splitLines :: String -> [String]
splitLines str = lines str

-- Example Input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here", "      "]
-- Example Output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here"]
removeEmptyLines :: [String] -> [String]
removeEmptyLines sentences = filter (not . isBlank) sentences where
    isBlank :: String -> Bool
    isBlank = null . dropWhile isSpace

--------------  END OF LINE SPLITTING FUNCTIONS --------------



-------------- START OF HEADER FUNCTIONS --------------
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
getHeaders list = filter validateFormatHeader list where

    -- Example Input: "#view:tree"
    -- Example output: True
    -- This function verifies that the format of a header is valid
    -- "#view:tree" is valid but so is "#chocolate:fountain" because only the format is valid
    validateHeaderFormat :: String -> Bool
    validateHeaderFormat ('#':rest) =
        case span isAlpha rest of
            (firstHalf, ':':rest) -> isWord firstHalf && isWord rest
            otherwise -> False
    validateHeaderFormat _ = False

-- Exa
identifyHeaders :: String -> (String, String)
identifyHeaders ('#':rest) = identifyHeaders rest
identifyHeaders header = second (drop 1) (break (== ':') header)

-- Example Input: "#view:tree"
-- Example Output: "view"
getKey :: String -> String
getKey [] = []
getKey ('#':xs) = getKey xs
getKey (':':_) = []
getKey (x:xs) = x : getKey xs

-- Example Input: "#view:tree"
-- Example Output: "tree"
getValue :: String -> String
getValue []       = []
getValue (':':xs) = xs
getValue (_:xs)   = getValue xs




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
        getContentString ('@':_) = []
        getContentString (x:xs) = x : getContentString xs


seperateString :: String -> [StyledText]
seperateString "*" = ""
seperateString [] = []
seperateString (x:xs)
    | x == '*' = seperateString xs 
    | otherwise = x : seperateString xs



{- -- Example input "*Hello*"
-- Example output True
-- Example input "**Hello**"
-- Example output True
-- Example input "*hello" 
-- Example output False
-- Example input "** hello"
-- Example output False  -}
verifyFormattingComplete :: String -> Bool
verifyFormattingComplete string = verifyFirstFormatting string && verifyFirstFormatting (reverse string) where
    verifyFirstFormatting :: String -> Bool
    verifyFirstFormatting ('*':'*':xs) = True
    verifyFirstFormatting ('*':xs) = True
    verifyFirstFormatting _ = False

removeFirstFormattingDelimiters :: String -> String
removeFirstFormattingDelimiters [] = []
removeFirstFormattingDelimiters ('*':xs) = xs

-- Example input "*hello*"
-- Example output "hello"
formattingDelimiters :: String -> StyledText
formattingDelimiters ('*':'*':xs) = Bold (reverse (removeFirstFormattingDelimiters (reverse (removeFirstFormattingDelimiters xs))))
formattingDelimiters ('*':xs) = Italic (reverse (removeFirstFormattingDelimiters (reverse (removeFirstFormattingDelimiters xs))))
    

-- Example input "/*hello*/"
-- Example output "hello"
removeDelimiters :: String -> String
removeDelimiters str = reverse (removeFirst (reverse (removeFirst str))) where
    removeFirst ('/':'*':xs) = xs
    removeFirst xs           = xs


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
