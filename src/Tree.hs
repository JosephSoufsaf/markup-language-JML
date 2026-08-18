module Tree (insertTag, mergeTag) where

import AST


-- Input:  insertTag [Tag "shopping", Tag "walmart"] (Content "Buy milk") []
-- Output: [TagNode (Tag "shopping") [TagNode (Tag "walmart") [ContentNode (Content "Buy milk")]]]
insertTag :: [Tag] -> Content -> [DocTree] -> [DocTree]
insertTag [] content tree = ContentNode content : tree
insertTag (x:xs) content tree = mergeTag (TagNode x (insertTag xs content [])) tree


-- Input:  insertTag [Tag "shopping", Tag "homedepot"] (Content "Buy paint")
--[TagNode (Tag "shopping") [TagNode (Tag "walmart") [ContentNode (Content "Buy milk")]]]
-- Output: [TagNode (Tag "shopping") [TagNode (Tag "homedepot") [ContentNode (Content "Buy paint")], TagNode (Tag "walmart") [ContentNode (Content "Buy milk")]]]
mergeTag :: DocTree -> [DocTree] -> [DocTree]
mergeTag tag [] = [tag]
mergeTag (TagNode tag children) ((TagNode tagValue kids) : xs)
    | tag == tagValue = (TagNode tagValue (children ++ kids)) : xs
    | otherwise = (TagNode tagValue kids) : mergeTag (TagNode tag children) xs
mergeTag tag (ContentNode content: xs) = ContentNode content : (mergeTag tag xs)

-- findAmongSiblings :: Tag -> [DocTree] -> Maybe DocTree
-- findAmongSiblings tag [] = Nothing
-- findAmongSiblings tag ((TagNode tagValue _ ) :xs)
--     | tag == tagValue = Just (TagNode tagValue children )
--     | otherwise = findAmongSiblings tag xs
-- findAmongSiblings tag (ContentNode content: xs) = findAmongSiblings tag xs

-- findAmongChildren :: Tag -> DocTree -> Maybe DocTree
-- findAmongChildren tag (TagNode tagValue children) = findAmongSiblings tag children
-- findAmongChildren tag (ContentNode Content) = Nothing

-- insertSibling :: Tag -> Content -> [DocTree] -> [DocTree]
-- insertSibling [] content tree = 
-- insertSibling (x:xs) content tree = (TagNode x children) : insertSibling xs