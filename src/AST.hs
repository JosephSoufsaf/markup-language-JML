module AST (Note(..), Content(..), Tag(..), Document(..), Group (..), GroupDocument(..)) where
data Note = Note Content [Tag]
    deriving Show

data Content = Content String
    deriving Show

data Tag = Tag String
    deriving (Show, Eq)

data Document = Document [Note]
    deriving Show

data Group = Group Tag [Content]
    deriving Show

data GroupDocument = GroupDocument [Group]
    deriving Show



