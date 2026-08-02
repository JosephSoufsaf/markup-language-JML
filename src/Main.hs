import Text.XHtml (content)
import GHC.Data.ShortText (ShortText(contents))
main :: IO ()
main = do
    contents <- readFile "wordlist.txt"
    putStrLn contents



