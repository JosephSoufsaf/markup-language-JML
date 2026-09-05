module AST (Note(..), Content(..), Tag(..), Document(..), DocTree(..)) where


-- data Group = Group Tag [Content]
--     deriving Show

-- data GroupDocument = GroupDocument [Group]
--     deriving Show

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
    (Content idx1 _) == (Content idx2 _) = idx1 == idx2

instance Ord Content where
    (Content idx1 _) <= (Content idx2 _) = idx1 <= idx2