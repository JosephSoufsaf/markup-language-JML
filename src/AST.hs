module AST (Note(..), Content(..), Tag(..), Document(..), DocTree(..)) where

data Note = Note Content [Tag]
    deriving (Show, Eq)

data Content = Content Int String | Drawing Int String
    deriving (Show)

data Tag = Tag String
    deriving (Show, Eq, Ord)

data Document = Document [Note]
    deriving (Show, Eq)

data DocTree = TagNode Tag [DocTree]  | ContentNode Content
    deriving (Show, Eq)

instance Eq Content where
    (Drawing idx1 _) == (Drawing idx2 _) = idx1 == idx2
    (Content idx1 _) == (Content idx2 _) = idx1 == idx2
    _ == _ = False

instance Ord Content where
    (Content idx1 _) <= (Content idx2 _) = idx1 <= idx2
    (Drawing idx1 _) <= (Drawing idx2 _) = idx1 <= idx2










