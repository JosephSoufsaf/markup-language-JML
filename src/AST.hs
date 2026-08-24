module AST (Note(..), Content(..), Tag(..), Document(..), DocTree(..)) where


-- data Group = Group Tag [Content]
--     deriving Show

-- data GroupDocument = GroupDocument [Group]
--     deriving Show

data Note = Note Content [Tag]
    deriving (Show, Eq)

data Content = Content Int String
    deriving (Show, Eq)

data Tag = Tag String
    deriving (Show, Eq, Ord)

data Document = Document [Note]
    deriving (Show, Eq)

data DocTree = TagNode Tag [DocTree]  | ContentNode Content
    deriving (Show, Eq)









            
-- [Tag "shopping", Tag "walmart", Tag "instacart"]








-- A tree is empty 
-- or it has a node with no children and no sibling 
-- or it has node with children and no sibling 
-- or it has a node with both children and siblings



-- Buy milk @shopping@walmart
-- Finish JML parser @todo@haskell
-- What the hell is going here @hello@bye@and this is my life
-- Just some thought with no tag at all
-- Pick up dry cleaning @errands

