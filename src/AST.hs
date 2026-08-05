module AST (Note(..), Content(..), Tag(..), Document(..)) where
    
data Note = Note Content (Maybe Tag)
    deriving Show

data Content = Content String
    deriving Show

data Tag = Tag String
    deriving Show

data Document = Document [Note]
    deriving Show