module Tree (insertTag, mergeTag, buildTree, sortTreeAlphabetical) where

import AST
import Map
import Data.List (sortBy)
import Data.Ord (comparing)


-- Input:  insertTag [Tag "shopping", Tag "walmart"] (Content "Buy milk") []
-- Output: [TagNode (Tag "shopping") [TagNode (Tag "walmart") [ContentNode (Content "Buy milk")]]]
insertTag :: [Tag] -> Content -> [DocTree] -> [DocTree]
insertTag [] content tree = ContentNode content  : tree
insertTag (x:xs) content tree = mergeTag (TagNode x (insertTag xs content [])) tree

mergeChildren :: [DocTree] -> [DocTree] -> [DocTree]
mergeChildren newChildren existingChildren = foldr mergeTag existingChildren newChildren

mergeTag :: DocTree -> [DocTree] -> [DocTree]
mergeTag (ContentNode content) siblings = (ContentNode content) : siblings
mergeTag tag [] = [tag]
mergeTag (TagNode tag children) ((TagNode tagValue kids) : xs)
    | tag == tagValue = (TagNode tagValue (mergeChildren children kids)) : xs
    | otherwise = (TagNode tagValue kids) : mergeTag (TagNode tag children) xs
mergeTag tag ((ContentNode content) : xs) = (ContentNode content) : (mergeTag tag xs)



-- Example 1
-- Input:  [Note (Content "Buy milk") [Tag "shopping"]]
-- Output: [TagNode (Tag "shopping") [ContentNode (Content "Buy milk")]]

-- Example 2
-- Input:  [Note (Content "Buy milk") [Tag "shopping", Tag "walmart"], Note (Content "Buy paint") [Tag "shopping", Tag "homedepot"]]
-- Output: [TagNode (Tag "shopping") [TagNode (Tag "homedepot") [ContentNode (Content "Buy paint")], TagNode (Tag "walmart") [ContentNode (Content "Buy milk")]]]

-- Example 3
-- Input:  [Note (Content "Buy milk") [Tag "shopping"], Note (Content "No tag here") []]
-- Output: [ContentNode (Content "No tag here"), TagNode (Tag "shopping") [ContentNode (Content "Buy milk")]]


-- Example 4
-- Input:  [Note (Content "Buy milk") [Tag "shopping"], Note (Content "Finish parser") [Tag "todo"]]
-- Output: [TagNode (Tag "todo") [ContentNode (Content "Finish parser")], TagNode (Tag "shopping") [ContentNode (Content "Buy milk")]]

buildTree :: [Note] -> [DocTree]
buildTree [] = []
buildTree (n:ns) =
    case getTags n of
        Nothing   -> ContentNode (getContent n) : buildTree ns
        Just tags -> insertTag tags (getContent n) (buildTree ns)


extractString :: DocTree -> String
extractString (TagNode (Tag name) _) = name
extractString (ContentNode (Content _ text)) = text

sortTreeAlphabetical :: [DocTree] -> [DocTree]
sortTreeAlphabetical trees = map sortChildren (sortBy (comparing extractString) trees)
  where
    sortChildren :: DocTree -> DocTree
    sortChildren (TagNode tag children) = TagNode tag (sortTreeAlphabetical children)
    sortChildren leaf = leaf










