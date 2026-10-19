module AST where

data Note = Note Content [Tag]
    deriving (Show, Eq)

data Content = Content Int [StyledText] | Drawing Int String
    deriving (Show)

data Tag = Tag String
    deriving (Show, Eq, Ord)

data Document = Document [Note]
    deriving (Show, Eq)

data DocTree = TagNode Tag [DocTree] | ContentNode Content
    deriving (Show, Eq)

data StyledText = Italic String | Bold String | Plain String
    deriving (Show, Eq)

contentIndex :: Content -> Int
contentIndex (Content i _) = i
contentIndex (Drawing i _) = i

instance Eq Content where
    a == b = contentIndex a == contentIndex b

instance Ord Content where
    compare a b = compare (contentIndex a) (contentIndex b)
