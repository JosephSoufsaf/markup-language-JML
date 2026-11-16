module AST where

data Note = Note Content [Tag]
    deriving (Show, Eq)

-- A piece of content is either ordinary styled text, or a special block
-- (@python{...}, @math{...}, @drawing{...}) whose body is kept as raw text.
data Content = Content Int [StyledText]
    | Python Int String
    | Math Int String
    | Drawing Int String
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
contentIndex (Python i _)  = i
contentIndex (Math i _)    = i
contentIndex (Drawing i _) = i

instance Eq Content where
    a == b = contentIndex a == contentIndex b

instance Ord Content where
    compare a b = compare (contentIndex a) (contentIndex b)

