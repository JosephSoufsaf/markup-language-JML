{-# LANGUAGE OverloadedStrings #-}

import System.Environment (getArgs)
import System.Process (callCommand)
import Lucid (renderToFile, style_, toHtml, Html)
import Parser
import AST
import Map
import Tree
import Render
import qualified Data.Map as Map

defaultStyle :: Html ()
defaultStyle = style_ "details { margin-left: 1.5em; } summary { cursor: pointer; }"

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

            let notes = getNotes (parseDocument text)

            if viewChoice == "tree"
                then do
                    let builtTree = buildTree notes
                    let sortedTree = if sortChoice == "alphabetical"
                                        then sortTreeAlphabetical builtTree
                                        else builtTree
                    renderToFile "output.html" (defaultStyle <> renderTree sortedTree)
                else do
                    let grouped = singleTagSorting (notesToPairs notes)
                    let flatHtml = renderNote (sortMiscLast (Map.toList grouped))
                    renderToFile "output.html" (defaultStyle <> flatHtml)

            callCommand "start output.html"
        _ -> putStrLn "Usage: jml <path-to-.jml-file>"