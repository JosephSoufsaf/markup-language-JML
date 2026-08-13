module AST (Note(..), Content(..), Tag(..), Document(..)) where

data Note = Note Content [Tag]
    deriving Show

data Content = Content String
    deriving Show

data Tag = Tag String
    deriving (Show, Eq, Ord)

data Document = Document [Note]
    deriving Show



-- data Group = Group Tag [Content]
--     deriving Show

-- data GroupDocument = GroupDocument [Group]
--     deriving Show