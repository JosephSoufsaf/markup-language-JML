module Parser where
import AST
import Data.Bifunctor (second)
import Data.Char (isSpace, isAlpha)
import Data.List (isPrefixOf, intercalate)


--------------  START OF LINE SPLITTING FUNCTIONS --------------

{-
by the end of the line splitting functions should have:

1- Kept the single line notes with tags unchanged -> "hello this is a note @fake"
2- turned any multiline tag blocks into their matching single line notes -> "@wow{hello this is incredible @good}" -> "hello this is incredible @wow@good"
3- kept any special block tags unchanged "@python{# this is a python comment }"


Before going through line splitting functions:

#view:tree
@python{
#this is python code
if x > 5:
    return x
}@coding@mean
@wow{
this is impressive @notReally
how does this work @goodlord
}


After going through line splitting functions:

["#view:tree", "@python{\n#this is python code\nif x > 5:\n\treturn x\n}@coding@mean", "this is impressive@wow@notReally", "how does this work@wowgoodlord"]

-}


-- Example input:  "#view:tree\nBuy milk @shopping\nFinish JML parser @todo\nNo tag here\n@multi{hello\nWhat is going on @maybe\nChocolate is whats up @BigMaybe\n}"
-- Example output: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here", "@multi{hello", "What is going on @maybe", "Chocolate is whats up @BigMaybe", "}"]
splitLines :: String -> [String]
splitLines str = lines str


-- Example input:  ["#view:tree", "", "Buy milk @shopping", "   ", "No tag here"]
-- Example output: ["#view:tree", "Buy milk @shopping", "No tag here"]
removeEmptyLines :: [String] -> [String]
removeEmptyLines = filter (not . all isSpace)


-- Example input: ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here", "@python{hello", "What is going on @maybe", "Chocolate is whats up @BigMaybe", "}"]
-- Example output: ["view:tree", Buy milk @shopping, Finish JML parser @todo, No tag here, "@python{hello\nWhat is going on @maybe\nChocolate is whats up@BigMaybe}"]
mergeSpecialBlocks :: [String] -> [String]
mergeSpecialBlocks [] = []
mergeSpecialBlocks (x:xs)
    | isSpecialBlock x = intercalate "\n" (x : block ++ take 1 afterBlock) : mergeSpecialBlocks (drop 1 afterBlock)
    | otherwise = x : mergeSpecialBlocks xs
    where
        (block, afterBlock) = break isBlockEnd xs


-- Example input:  "}" or "}@coding@mean"
-- Example output: True
isBlockEnd :: String -> Bool
isBlockEnd line = isPrefixOf "}" (trimEdges line)


-- Example input:  ["avant", "@multi{", "what is going on @maybe", "chocolate is whats up @bigmaybe", "}", "milieu", "@other{", "hello @x", "}", "apres"]
-- Example output: ["avant", "what is going on @multi@maybe", "chocolate is whats up @multi@bigmaybe", "milieu", "hello @other@x", "apres"]
processBlocks :: [String] -> [String]
processBlocks [] = []
processBlocks strings =
    let (beforeMultiLine, afterMultiLine) = break isMultiLine strings
        (block, afterBlock)               = break isEndBrace afterMultiLine
    in  beforeMultiLine ++ tagBlock block ++ processBlocks (drop 1 afterBlock)


-- Example input:  "}" or "  } "
-- Example output: True
isEndBrace :: String -> Bool
isEndBrace line = trimEdges line == "}"


-- Example input:  ["@multi{", "what is going on @maybe", "chocolate is whats up @bigmaybe"]
-- Example output: ["what is going on @multi@maybe", "chocolate is whats up @multi@bigmaybe"]
tagBlock :: [String] -> [String]
tagBlock [] = []
tagBlock [_] = []
tagBlock (x:y:xs)
    | all isSpace y = tagBlock (x:xs)
    | otherwise = (getContentString y ++ tag ++ dropWhile (/= '@') y) : tagBlock (x:xs)
    where
        tag = getTagBlock x


-- Example input:  "@shopping{" or "@shopping{hello"
-- Example output: True
isMultiLine :: String -> Bool
isMultiLine line = case trimEdges line of
    ('@':rest) -> '{' `elem` rest && last rest /= '}' && not (isSpecialBlock line)
    _ -> False

-- Example input : "@shopping{hello"
-- Example output : "@shopping"
-- Example input: "@shopping@maybe{hello"
-- Example output: "@shopping@maybe"
getTagBlock :: String -> String
getTagBlock line = takeUntil "{" (trimEdges line)


-- Example input : "@shopping{hello"
-- Example output : "hello"
getBlockOpeningText :: String -> String
getBlockOpeningText line = dropUntil "{" line


-- Example Input: "@python{"
-- Example output: True
-- Example Input: "@hello{"
-- Example output: False
isSpecialBlock :: String -> Bool
isSpecialBlock [] = False
isSpecialBlock (x:xs)
    | x == '@' && ('{' `elem` xs) && (takeUntil "{" xs `elem` ["python", "math", "drawing"]) = True
    | otherwise = False

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
        _ -> False
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


-- Example Input : "view" "flat" ["#view:tree", "#sort:chronological"]
-- Example Output: "tree"   (the default, "flat", is returned if the key is missing)
findHeaderValue :: String -> String -> [String] -> String
findHeaderValue key def headers =
    case [v | h <- headers, let (k, v) = identifyHeaders h, k == key] of
        (v:_) -> v
        []    -> def

-- Example Input : ["#view:tree"]
-- Example Output: "tree"
findViewValue :: [String] -> String
findViewValue = findHeaderValue "view" "flat"



-- Example Input : ["#sort:chronological"]
-- Example Output: "chronological"
findSortValue :: [String] -> String
findSortValue = findHeaderValue "sort" "alphabetical"

-------------- END OF HEADER FUNCTIONS --------------




-------------- START OF INDEX ASSIGNING FUNCTIONS --------------
-- Example Input: ["@python{\n#this is python code\nif x > 5:\n\treturn x\n}@coding@mean", "this is impressive@wow@notReally", "how does this work@wowgoodlord"]
-- Example output: [(0, "@python{\n#this is python code\nif x > 5:\n\treturn x\n}@coding@mean" ), (1, "this is impressive@wow@notReally"), (2, "how does this work@wowgoodlord")]
assignIndex :: [String] -> [(Int, String)]
assignIndex lignes = zip [0..] lignes


-------------- END OF INDEX ASSIGNING FUNCTIONS --------------


-------------- START OF PARSING FUNCTIONS --------------
{-
At the start of the parsing functions the string that comes from the file should look something like this

[(0, "@python{\n#this is python code\nif x > 5:\n\treturn x\n}@coding@mean" ),
(1, "this is impressive@wow@notReally"), 
(2, "how does this work@wowgoodlord")]

It should be a list of strings with each an index
-}


-- Example Input: takeUntil "{" "python{abc"
-- Example output: "python"

-- Example Input: takeUntil "ab" "xxayy"
-- Example output: "xxayy"
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
-- Example output : "Hello what is going on "
getContentString :: String -> String
getContentString [] = []
getContentString ('@':_) = []
getContentString (x:xs) = x : getContentString xs

-- Example Input : (0, "Hello **what** is going on @aCertainTag")
-- Example output : Content 0 [Plain "Hello ", Bold "what", Plain " is going on "]
parseContent :: (Int, String) -> Content
parseContent (index, line) = Content index (stringType (getContentString line) [])

-- Example input:  "Buy milk @shopping@walmart"
-- Example output: "shopping@walmart"
dropUntilTag :: String -> String
dropUntilTag [] = []
dropUntilTag ('@':xs) = xs
dropUntilTag (_:xs) = dropUntilTag xs


-- Example input:  "shopping@walmart"
-- Example output: ["shopping", "walmart"]
getTags :: String -> [String]
getTags s = case break (== '@') s of
    (tag, [])     -> [tag]
    (tag, _:rest) -> tag : getTags rest


-- Example input:  ["shopping", "walmart"]
-- Example output: [Tag "shopping", Tag "walmart"]
parseTags :: [String] -> [Tag]
parseTags = map Tag


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
    removeSpaces (c:xs) | isSpace c = removeSpaces xs
    removeSpaces xs = xs


{-
Example input:
@python{

x = 5
def init():
    if x > 4:
       return x 
}@hello@goodbye

Example output:
Python ["hello", "goodbye"] "x = 5\ndef init()\n\t if x > 4:\n\t return x"
-}
parseUniqueBlock :: (Int, String) -> UniqueBlock
parseUniqueBlock (int, string)
    | getTagBlock string == "@python" = Python int (parseTags (getSpecialBlockTags string)) (takeUntil "}" (dropUntil "{" string))
    | getTagBlock string == "@drawing" = Drawing int (parseTags (getSpecialBlockTags string)) (takeUntil "}" (dropUntil "{" string)) 
    | getTagBlock string == "@math" = Math int (parseTags (getSpecialBlockTags string)) (takeUntil "}" (dropUntil "{" string))

{-
Example input:
@python{

x = 5
def init():
    if x > 4:
       return x 
}@hello@goodbye

Example output:
["Hello", "goodbye"]

-}
getSpecialBlockTags :: String -> [String]
getSpecialBlockTags string = getTags (drop 1 (dropUntil "}" string))


-- Example Input: (0, "Buy milk @shopping@walmart")
-- Example Output: Note (Content 0 [Plain "Buy milk "]) [Tag "shopping", Tag "walmart"]
-- A line with no @ gets no tags (getTags "" would otherwise give [Tag ""]).
parseNote :: (Int, String) -> Note
parseNote (index, line)
    | '@' `elem` line = Note (parseContent (index, line)) (trimTags (parseTags (getTags (dropUntilTag line))))
    | otherwise       = Note (parseContent (index, line)) []


-- Example Input: the full text of a .jml file
-- Example Output: Document [Note ...]
parseDocument :: String -> Document
parseDocument text =
    Document (map parseNote
        (assignIndex
            (processBlocks
                (mergeSpecialBlocks
                    (removeHeaders
                        (removeEmptyLines
                            (splitLines text)))))))
-------------- END OF PARSING FUNCTIONS --------------
