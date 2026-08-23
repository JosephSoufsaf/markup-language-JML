{-# LANGUAGE OverloadedStrings #-}

import System.Environment (getArgs)
import System.Process (callCommand)
import Lucid (renderToFile, h1_, style_, toHtml, Html)
import Parser
import AST
import Organizer
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
            let notes = getNotes (parseDocument text)

            -- flat pipeline
            let grouped = singleTagSorting (notesToPairs notes)
            let flatHtml = renderNote (sortMiscLast (Map.toList grouped))

            -- tree pipeline
            let tree = sortTreeAlphabetical (buildTree notes)
            let treeHtml = renderTree tree

            renderToFile "output.html" $
                defaultStyle <>
                h1_ "Flat view" <> flatHtml <>
                h1_ "Tree view" <> treeHtml

            callCommand "start output.html"
        _ -> putStrLn "Usage: jml <path-to-.jml-file>"