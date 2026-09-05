{-# LANGUAGE OverloadedStrings #-}

import System.Environment (getArgs)
import System.Process (callCommand)
import Lucid (renderToFile)
import Parser
import AST
import Organizer
import Tree
import Render
import qualified Data.Map as Map

stripLeadingDotSlash :: String -> String
stripLeadingDotSlash ('.':'\\':rest) = rest
stripLeadingDotSlash ('.':'/':rest) = rest
stripLeadingDotSlash s = s

toHtmlFilename :: String -> String
toHtmlFilename filename = takeWhile (/= '.') (stripLeadingDotSlash filename) ++ ".html"

main :: IO ()
main = do
    args <- getArgs
    case args of
        [filename] -> do
            text <- readFile filename
            let allLines = splitLines text
            let headerLines = getHeaders allLines
            let viewChoice = findViewValue headerLines
            let sortChoice = findSortValue headerLines
            let outputFile = toHtmlFilename filename

            let notes = getNotes (parseDocument text)

            if viewChoice == "tree"
                then do
                    let builtTree = buildTree notes
                    let sortedTree = if sortChoice == "alphabetical"
                                        then sortTreeAlphabetical builtTree
                                        else builtTree
                    renderToFile outputFile (defaultStyle <> renderTree sortedTree)
                else do
                    let grouped = singleTagSorting (notesToPairs notes)
                    let flatHtml = renderNote (sortMiscLast (Map.toList grouped))
                    renderToFile outputFile (defaultStyle <> flatHtml)

            callCommand ("start " ++ outputFile)
        _ -> putStrLn "Usage: jml <path-to-.jml-file>"