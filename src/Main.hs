import Parser 

main = do
    text <- readFile "notes.jml"
    print (parseDocument text) 