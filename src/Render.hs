{-# LANGUAGE OverloadedStrings #-}

module Render where

import Lucid
import AST
import Organizer

-- Example input:  [(Tag "shopping", [Content "Buy milk"]), (Tag "todo", [Content "Finish JML parser"])]
-- Example output: <details><summary>shopping</summary><p>Buy milk</p></details><details><summary>todo</summary><p>Finish JML parser</p></details>
renderNote :: [(Tag, [Content])] -> Html ()
renderNote [] = mempty
renderNote ((Tag tag, contents) : xs) = details_ (summary_ (toHtml tag) <> renderContent contents) <> renderNote xs where
    
    -- Example input:  [Content "Buy milk", Content "Buy eggs"]
    -- Example output: <p>Buy milk</p><p>Buy eggs</p>
    renderContent :: [Content] -> Html ()
    renderContent [] = mempty
    renderContent (Content _ content : xs) = p_ (toHtml content) <> renderContent xs

renderTree :: [DocTree] -> Html ()
renderTree [] = mempty
renderTree trees = mapM_ renderNode trees
  where
    renderNode :: DocTree -> Html ()
    renderNode (TagNode (Tag name) children) = details_ (summary_ (toHtml name) <> renderTree children)
    renderNode (ContentNode (Content _ text)) = p_ (toHtml text)




