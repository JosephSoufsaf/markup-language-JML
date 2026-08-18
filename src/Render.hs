{-# LANGUAGE OverloadedStrings #-}

module Render where

import Lucid
import AST
import Organizer

renderNote :: [(Tag, [Content])] -> Html ()
renderNote [] = mempty
renderNote ((Tag tag, contents) : xs) = (h2_ (toHtml tag) <> ul_ (renderContent contents)) <> renderNote xs where
    
    renderContent :: [Content] -> Html ()
    renderContent [] = mempty
    renderContent (Content content : xs) = li_ (toHtml content) <> renderContent xs