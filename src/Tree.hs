module Tree (insertTag, mergeTag, buildTree, sortTreeAlphabetical, sortTreeChronological) where

import AST
import Organizer
import Data.List (sortBy)
import Data.Ord (comparing)


-- Example input:  [Tag "shopping", Tag "walmart"] (Content 0 [Plain "Buy milk"]) []
-- Example output: [TagNode (Tag "shopping") [TagNode (Tag "walmart") [ContentNode (Content 0 [Plain "Buy milk"])]]]
insertTag :: [Tag] -> Content -> [DocTree] -> [DocTree]
insertTag [] content tree = ContentNode content : tree
insertTag (x:xs) content tree = mergeTag (TagNode x (insertTag xs content [])) tree


-- Example input:  (TagNode (Tag "shopping") [ContentNode (Content 1 [Plain "b"])]) [TagNode (Tag "shopping") [ContentNode (Content 0 [Plain "a"])]]
-- Example output: [TagNode (Tag "shopping") [ContentNode (Content 1 [Plain "b"]), ContentNode (Content 0 [Plain "a"])]]
mergeTag :: DocTree -> [DocTree] -> [DocTree]
mergeTag (ContentNode content) siblings = ContentNode content : siblings
mergeTag tag [] = [tag]
mergeTag (TagNode tag children) ((TagNode tagValue kids) : xs)
    | tag == tagValue = TagNode tagValue (foldr mergeTag kids children) : xs
    | otherwise = TagNode tagValue kids : mergeTag (TagNode tag children) xs
mergeTag tag (ContentNode content : xs) = ContentNode content : mergeTag tag xs


-- Example input:  [Note (Content 0 [Plain "Buy milk"]) [Tag "shopping"], Note (Content 1 [Plain "No tag"]) []]
-- Example output: [ContentNode (Content 1 [Plain "No tag"]), TagNode (Tag "shopping") [ContentNode (Content 0 [Plain "Buy milk"])]]
buildTree :: [Note] -> [DocTree]
buildTree [] = []
buildTree (n:ns) =
    case getTags n of
        Nothing   -> ContentNode (getContent n) : buildTree ns
        Just tags -> insertTag tags (getContent n) (buildTree ns)


-- Example input:  Content 0 [Plain "Buy ", Bold "milk"]
-- Example output: "Buy milk"
contentText :: Content -> String
contentText (Content _ styled) = concatMap styledText styled
  where
    styledText (Italic s) = s
    styledText (Bold s)   = s
    styledText (Plain s)  = s
contentText (Drawing _ text)   = text


-- Example input:  TagNode (Tag "shopping") []
-- Example output: "shopping"
extractString :: DocTree -> String
extractString (TagNode (Tag name) _) = name
extractString (ContentNode content)  = contentText content


-- Example input:  [TagNode (Tag "zoo") [], TagNode (Tag "shopping") []]
-- Example output: [TagNode (Tag "shopping") [], TagNode (Tag "zoo") []]
sortTreeAlphabetical :: [DocTree] -> [DocTree]
sortTreeAlphabetical trees = map sortChildren (sortBy (comparing extractString) trees)
  where
    sortChildren :: DocTree -> DocTree
    sortChildren (TagNode tag children) = TagNode tag (sortTreeAlphabetical children)
    sortChildren leaf = leaf


-- Example input:  TagNode (Tag "shopping") [ContentNode (Content 2 [Plain "b"]), ContentNode (Content 0 [Plain "a"])]
-- Example output: 0
minIndex :: DocTree -> Int
minIndex (ContentNode content)  = contentIndex content
minIndex (TagNode _ children)   = minimum (maxBound : map minIndex children)


-- Example input:  [TagNode (Tag "zoo") [ContentNode (Content 1 [Plain "b"])], TagNode (Tag "shopping") [ContentNode (Content 0 [Plain "a"])]]
-- Example output: [TagNode (Tag "shopping") [ContentNode (Content 0 [Plain "a"])], TagNode (Tag "zoo") [ContentNode (Content 1 [Plain "b"])]]
sortTreeChronological :: [DocTree] -> [DocTree]
sortTreeChronological trees = map sortChildren (sortBy (comparing minIndex) trees)
  where
    sortChildren :: DocTree -> DocTree
    sortChildren (TagNode tag children) = TagNode tag (sortTreeChronological children)
    sortChildren leaf = leaf
