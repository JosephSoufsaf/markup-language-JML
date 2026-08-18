{-# LANGUAGE OverloadedStrings #-}

module Render where

import Lucid
import AST
import Organizer

-- Example input:  [(Tag "shopping", [Content "Buy milk"]), (Tag "todo", [Content "Finish JML parser"])]
-- Example output: <h2>shopping</h2><ul><li>Buy milk</li></ul><h2>todo</h2><ul><li>Finish JML parser</li></ul>
renderNote :: [(Tag, [Content])] -> Html ()
renderNote [] = mempty
renderNote ((Tag tag, contents) : xs) = (h2_ (toHtml tag) <> ul_ (renderContent contents)) <> renderNote xs where
    
    -- Example input:  [Content "Buy milk", Content "Buy eggs"]
    -- Example output: <li>Buy milk</li><li>Buy eggs</li>
    renderContent :: [Content] -> Html ()
    renderContent [] = mempty
    renderContent (Content content : xs) = li_ (toHtml content) <> renderContent xs