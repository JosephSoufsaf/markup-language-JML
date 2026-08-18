import System.Environment (getArgs)
import System.Process (callCommand)
import Lucid (renderToFile)
import Parser
import AST
import Organizer
import Render
import qualified Data.Map as Map

main :: IO ()
main = do
    args <- getArgs
    case args of
        [filename] -> do
            text <- readFile filename
            let notes = getNotes (parseDocument text)
            let grouped = organizeByTag (notesToPairs notes)
            renderToFile "output.html" (renderNote (Map.toList grouped))
            callCommand "start output.html"
        _ -> putStrLn "Usage: jml <path-to-.jml-file>"