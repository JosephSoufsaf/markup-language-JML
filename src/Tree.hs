module Tree (insertTag, mergeTag, buildTree, sortTreeAlphabetical, sortTreeChronological) where

import AST
import Organizer
import Data.List (sortBy)
import Data.Ord (comparing)


-- Output: [TagNode (Tag "shopping") [TagNode (Tag "walmart") [ContentNode (Content 0 [Plain "Buy milk"])]]]
insertTag :: [Tag] -> Content -> [DocTree] -> [DocTree]
insertTag [] content tree = ContentNode content : tree
insertTag (x:xs) content tree = mergeTag (TagNode x (insertTag xs content [])) tree

mergeTag :: DocTree -> [DocTree] -> [DocTree]
mergeTag (ContentNode content) siblings = ContentNode content : siblings
mergeTag tag [] = [tag]
mergeTag (TagNode tag children) ((TagNode tagValue kids) : xs)
    | tag == tagValue = TagNode tagValue (foldr mergeTag kids children) : xs
    | otherwise = TagNode tagValue kids : mergeTag (TagNode tag children) xs
mergeTag tag (ContentNode content : xs) = ContentNode content : mergeTag tag xs


buildTree :: [Note] -> [DocTree]
buildTree [] = []
buildTree (n:ns) =
    case getTags n of
        Nothing   -> ContentNode (getContent n) : buildTree ns
        Just tags -> insertTag tags (getContent n) (buildTree ns)


-- Plain text of a piece of content, used as the sort key.
contentText :: Content -> String
contentText (Content _ styled) = concatMap styledText styled
  where
    styledText (Italic s) = s
    styledText (Bold s)   = s
    styledText (Plain s)  = s
contentText (Drawing _ text)   = text

extractString :: DocTree -> String
extractString (TagNode (Tag name) _) = name
extractString (ContentNode content)  = contentText content

sortTreeAlphabetical :: [DocTree] -> [DocTree]
sortTreeAlphabetical trees = map sortChildren (sortBy (comparing extractString) trees)
  where
    sortChildren :: DocTree -> DocTree
    sortChildren (TagNode tag children) = TagNode tag (sortTreeAlphabetical children)
    sortChildren leaf = leaf


-- Earliest position in the file of any note at or under this node.
minIndex :: DocTree -> Int
minIndex (ContentNode content)  = contentIndex content
minIndex (TagNode _ children)   = minimum (maxBound : map minIndex children)

sortTreeChronological :: [DocTree] -> [DocTree]
sortTreeChronological trees = map sortChildren (sortBy (comparing minIndex) trees)
  where
    sortChildren :: DocTree -> DocTree
    sortChildren (TagNode tag children) = TagNode tag (sortTreeChronological children)
    sortChildren leaf = leaf
