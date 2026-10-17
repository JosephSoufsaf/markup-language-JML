{-# LANGUAGE OverloadedStrings #-}

import System.Environment (getArgs)
import System.Process (callCommand)
import System.Info (os)
import System.FilePath (replaceExtension)
import System.IO (openFile, hSetEncoding, hGetContents, IOMode(ReadMode), utf8)
import Lucid (renderToFile)
import Parser
import Organizer
import Tree
import Render
import qualified Data.Map as Map

toHtmlFilename :: String -> String
toHtmlFilename filename = replaceExtension filename "html"

openInBrowser :: String -> IO ()
openInBrowser file = callCommand command
  where
    command = case os of
        "mingw32" -> "start \"\" \"" ++ file ++ "\""
        "darwin"  -> "open \"" ++ file ++ "\""
        _         -> "xdg-open \"" ++ file ++ "\""

main :: IO ()
main = do
    args <- getArgs
    case args of
        [filename] -> do
            handle <- openFile filename ReadMode
            hSetEncoding handle utf8
            text <- hGetContents handle
            let allLines = splitLines text
            let headerLines = getHeaders allLines
            let viewChoice = findViewValue headerLines
            let sortChoice = findSortValue headerLines
            let outputFile = toHtmlFilename filename

            let notes = getNotes (parseDocument text)

            if viewChoice == "tree"
                then do
                    let builtTree = buildTree notes
                    let sortedTree = case sortChoice of
                                        "chronological" -> sortTreeChronological builtTree
                                        _               -> sortTreeAlphabetical builtTree
                    renderToFile outputFile (renderPage (renderTree sortedTree))
                else do
                    let grouped = Map.toList (singleTagSorting (notesToPairs notes))
                    let sorted = case sortChoice of
                                    "chronological" -> sortFlatChronological grouped
                                    _               -> sortFlatAlphabetical grouped
                    renderToFile outputFile (renderPage (renderMap (sortMiscLast sorted)))

            putStrLn ("Wrote " ++ outputFile)
            openInBrowser outputFile
        _ -> putStrLn "Usage: jml <path-to-.jml-file>"
