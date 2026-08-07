import Parser 
import AST
import Data.Map
import Data.Bool (Bool(True))
--Document [Note (Content "Buy milk ") (Just (Tag "shopping")),Note (Content "Finish JML parser ") (Just (Tag "todo")),Note (Content "No tag here") Nothing]





-- a bunch of random fucking functions I dont know what I will do with but I might need cause I am not good at recursions

getNotes :: Document -> [Note]
getNotes (Document notes) = notes

getTag :: Note -> Maybe Tag
getTag (Note _ Nothing)    = Nothing        
getTag (Note _ (Just tag)) = Just tag       

getContent :: Note -> Content
getContent (Note content _ ) = content

makeTuplesTagContent :: [Note] -> [(Maybe Tag , Content)] 
makeTuplesTagContent [] = [] 
makeTuplesTagContent (x:xs) = (getTag x, getContent x) : makeTuplesTagContent xs

makeListTag :: [Note] -> [Maybe Tag]
makeListTag [] = []
makeListTag (x:xs) = if getTag x != makeListTag xs then getTag x : 


-- Maybe some real useful stuff. 

isIn :: a -> [a] -> Bool
isIn element [] = False
isIn element (x:xs)
    | element == x = True
    | otherwise = False

-- foo :: [Note] -> (Tag, [Content])
-- foo (x:xs) = if (isNotIn (getTag x) (makeListTag (x:xs))) then (getTag x, getContent x :foo xs ) else  










 