{-# LANGUAGE OverloadedStrings #-}

module Render (renderMap, renderTree, defaultStyle, mermaidScript) where

import Lucid
import AST
import Organizer
import Data.Text (Text)

defaultStyle :: Html ()
defaultStyle = style_ styleText
  where
    styleText :: Text
    styleText =
        "body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; \
        \max-width: 720px; margin: 40px 40px; padding: 0 20px; \
        \line-height: 1.55; background-color: #1e1e1e; color: #d4d4d4; } \
        \h1 { font-size: 20px; font-weight: 600; margin: 28px 0 10px; color: #d4d4d4; } \
        \details { border-left: 2px solid #3c3c3c; padding-left: 14px; margin: 6px 0; } \
        \summary { font-weight: 600; cursor: pointer; padding: 2px 0; color: #569cd6; } \
        \summary:hover { color: #9cdcfe; } \
        \p { margin: 4px 0; color: #ce9178; } \
        \pre.mermaid { background-color: #252526; padding: 12px; border-radius: 4px; }"

mermaidScript :: Html ()
mermaidScript = do
    script_ [src_ "https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"] ("" :: Text)
    script_ ("mermaid.initialize({ startOnLoad: true, theme: 'dark' });" :: Text)

renderMap :: [(Tag, [Content])] -> Html ()
renderMap [] = mempty
renderMap ((Tag tag, contents) : xs) =
    details_ [open_ "open"] (summary_ (toHtml tag) <> renderContent contents) <> renderMap xs
  where
    renderContent :: [Content] -> Html ()
    renderContent [] = mempty
    renderContent (Content _ text : rest) = p_ (toHtml text) <> renderContent rest
    renderContent (Drawing _ text : rest) = pre_ [class_ "mermaid"] (toHtml text) <> renderContent rest

renderTree :: [DocTree] -> Html ()
renderTree trees = mapM_ renderTop trees
  where
    renderTop :: DocTree -> Html ()
    renderTop (TagNode (Tag name) children) =
        details_ [open_ "open"] (summary_ (toHtml name) <> renderNested children)
    renderTop (ContentNode (Content _ text)) = p_ (toHtml text)
    renderTop (ContentNode (Drawing _ text)) = pre_ [class_ "mermaid"] (toHtml text)

    renderNested :: [DocTree] -> Html ()
    renderNested = mapM_ renderNode

    renderNode :: DocTree -> Html ()
    renderNode (TagNode (Tag name) children) =
        details_ (summary_ (toHtml name) <> renderNested children)
    renderNode (ContentNode (Content _ text)) = p_ (toHtml text)
    renderNode (ContentNode (Drawing _ text)) = pre_ [class_ "mermaid"] (toHtml text)

