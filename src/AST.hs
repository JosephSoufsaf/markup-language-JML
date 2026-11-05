module AST where

data Note = Note Content [Tag] | UniqueBlock [Tag]
    deriving (Show, Eq)

data Content = Content Int [StyledText] 
    deriving (Show)

data Tag = Tag String
    deriving (Show, Eq, Ord) 

data Document = Document [Note]
    deriving (Show, Eq)

data DocTree = TagNode Tag [DocTree] | ContentNode Content
    deriving (Show, Eq)

data StyledText = Italic String | Bold String | Plain String
    deriving (Show, Eq)

data UniqueBlock = Python Int [Tag] String 
    | Math Int [Tag] String 
    | Drawing Int [Tag] String

contentIndex :: Content -> Int
contentIndex (Content i _) = i

instance Eq Content where
    a == b = contentIndex a == contentIndex b

instance Ord Content where
    compare a b = compare (contentIndex a) (contentIndex b)

