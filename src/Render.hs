{-# LANGUAGE OverloadedStrings #-}

module Render (renderMap, renderTree, renderPage, defaultStyle, mermaidScript) where

import Lucid
import AST
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

-- Wraps the body in a complete HTML document.
renderPage :: Html () -> Html ()
renderPage body = doctypehtml_ $ do
    head_ $ do
        meta_ [charset_ "UTF-8"]
        title_ "Notes"
        defaultStyle
        mermaidScript
    body_ body

renderStyled :: [StyledText] -> Html ()
renderStyled = mapM_ renderOne
  where
    renderOne (Italic s) = em_ (toHtml s)
    renderOne (Bold s)   = strong_ (toHtml s)
    renderOne (Plain s)  = toHtml s

renderContent :: Content -> Html ()
renderContent (Content _ styled) = p_ (renderStyled styled)
renderContent (Drawing _ text)   = pre_ [class_ "mermaid"] (toHtml text)

renderMap :: [(Tag, [Content])] -> Html ()
renderMap = mapM_ renderGroup
  where
    renderGroup (Tag tag, contents) =
        details_ [open_ "open"] (summary_ (toHtml tag) <> mapM_ renderContent contents)

renderTree :: [DocTree] -> Html ()
renderTree = mapM_ renderTop
  where
    renderTop :: DocTree -> Html ()
    renderTop (TagNode (Tag name) children) =
        details_ [open_ "open"] (summary_ (toHtml name) <> renderNested children)
    renderTop (ContentNode content) = renderContent content

    renderNested :: [DocTree] -> Html ()
    renderNested = mapM_ renderNode

    renderNode :: DocTree -> Html ()
    renderNode (TagNode (Tag name) children) =
        details_ (summary_ (toHtml name) <> renderNested children)
    renderNode (ContentNode content) = renderContent content
