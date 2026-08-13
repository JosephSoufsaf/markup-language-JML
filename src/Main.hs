import Parser
import AST
import Organizer  -- or whatever you've named the file with organizeByTag/notesToPairs
import qualified Data.Map as Map

main :: IO ()
main = do
    text <- readFile "notes.jml"
    let document = parseDocument text
    let notes = getNotes document
    let pairs = notesToPairs notes
    let grouped = organizeByTag pairs
    print grouped