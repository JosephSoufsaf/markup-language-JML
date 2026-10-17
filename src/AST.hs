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
    deriving (Show)

contentIndex :: Content -> Int
contentIndex (Content idx _) = idx
contentIndex (Drawing idx _) = idx

plainText :: [StyledText] -> String
plainText = concatMap flatten
  where
    flatten (Italic s) = s
    flatten (Bold s)   = s
    flatten (Plain s)  = s

contentText :: Content -> String
contentText (Content _ styled) = plainText styled
contentText (Drawing _ s)      = s

instance Eq Content where
    (Drawing idx1 _) == (Drawing idx2 _) = idx1 == idx2
    (Content idx1 _) == (Content idx2 _) = idx1 == idx2
    _ == _ = False

instance Ord Content where
    compare a b = compare (contentIndex a) (contentIndex b)
