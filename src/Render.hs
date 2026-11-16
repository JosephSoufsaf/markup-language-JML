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
        ":root { --bg: #ffffff; --fg: #1f2328; --muted: #656d76; --border: #d0d7de; --code-bg: #f6f8fa; --accent: #0969da; } \
        \@media (prefers-color-scheme: dark) { :root { --bg: #0d1117; --fg: #e6edf3; --muted: #8d96a0; --border: #30363d; --code-bg: #161b22; --accent: #4493f8; } } \
        \body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; max-width: 760px; margin: 0 auto; padding: 48px 24px; font-size: 16px; line-height: 1.6; background-color: var(--bg); color: var(--fg); } \
        \details { margin: 8px 0; } \
        \details details { margin-left: 4px; padding-left: 16px; border-left: 2px solid var(--border); } \
        \summary { font-weight: 600; cursor: pointer; padding: 4px 0; } \
        \summary:hover { color: var(--accent); } \
        \body > details > summary { font-size: 1.35em; padding-bottom: 6px; border-bottom: 1px solid var(--border); margin-bottom: 8px; } \
        \p { margin: 4px 0 10px; } \
        \pre { margin: 8px 0 16px; padding: 16px; overflow-x: auto; background-color: var(--code-bg); border: 1px solid var(--border); border-radius: 6px; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 85%; line-height: 1.45; } \
        \pre.mermaid { background-color: transparent; border: none; text-align: center; font-family: inherit; } \
        \code { font-family: inherit; }"

mermaidScript :: Html ()
mermaidScript = do
    script_ [src_ "https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"] ("" :: Text)
    script_ ("mermaid.initialize({ startOnLoad: true, theme: (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'default') });" :: Text)

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
renderContent (Python _ text)    = pre_ [class_ "code"] (code_ (toHtml text))
renderContent (Math _ text)      = pre_ [class_ "math"] (toHtml text)
renderContent (Drawing _ text)   = pre_ [class_ "mermaid"] (toHtml text)

renderMap :: [(Tag, [Content])] -> Html ()
renderMap = mapM_ renderGroup
  where
    renderGroup :: (Tag, [Content]) -> Html ()
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
        details_ [open_ "open"] (summary_ (toHtml name) <> renderNested children)
    renderNode (ContentNode content) = renderContent content
