module AST (Note(..), Content(..), Tag(..), Document(..), TagTree(..)) where


-- data Group = Group Tag [Content]
--     deriving Show

-- data GroupDocument = GroupDocument [Group]
--     deriving Show

data Note = Note Content [Tag]
    deriving Show

data Content = Content String
    deriving Show

data Tag = Tag String
    deriving (Show, Eq, Ord)

data Document = Document [Note]
    deriving Show

data DocTree = TagNode Tag [DocTree] | ContentNode Content


findAmongSiblings :: Tag -> [DocTree] -> Maybe DocTree
findAmongSiblings tag [] = Nothing
findAmongSiblings tag ((TagNode tagValue _ ) :xs)
    | tag == tagValue = Just (TagNode tagValue children )
    | otherwise = findAmongSiblings tag xs
findAmongSiblings tag (ContentNode content: xs) = findAmongSiblings tag xs

findAmongChildren :: Tag -> DocTree -> Maybe DocTree
findAmongChildren tag (TagNode tagValue children) = findAmongSiblings tag children
findAmongChildren tag (ContentNode Content) = Nothing


            









-- A tree is empty 
-- or it has a node with no children and no sibling 
-- or it has node with children and no sibling 
-- or it has a node with both children and siblings



-- Buy milk @shopping@walmart
-- Finish JML parser @todo@haskell
-- What the hell is going here @hello@bye@and this is my life
-- Just some thought with no tag at all
-- Pick up dry cleaning @errands

