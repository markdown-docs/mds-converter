module Markdown
  ( markdownToHtml,
  )
where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Parser (parseMarkdown)
import Types

markdownToHtml :: Text -> Text
markdownToHtml input = T.concat $ map renderElement $ Parser.parseMarkdown $ T.lines input

renderElement :: MDElement -> Text
renderElement element = case element of
  Paragraph elements -> T.concat [T.pack "<p>", T.concat (map renderElement elements), T.pack "</p>\n"]
  BlockQuote elements ->
    T.concat
      [ T.pack "<blockquote>\n",
        T.concat (map renderElement elements),
        T.pack "</blockquote>\n"
      ]
  LineBreak -> T.pack "<br />\n"
  Header level text id ->
    T.concat
      [T.pack "<h", T.pack (show level), T.pack " id=\"", id, T.pack "\">", escapeHtml text, T.pack "</h", T.pack (show level), T.pack ">\n"]
  Bold text -> T.concat [T.pack "<strong>", escapeHtml text, T.pack "</strong>"]
  Italic text -> T.concat [T.pack "<em>", escapeHtml text, T.pack "</em>"]
  BoldItalic text -> T.concat [T.pack "<strong><em>", escapeHtml text, T.pack "</em></strong>"]
  Strikethrough text -> T.concat [T.pack "<s>", escapeHtml text, T.pack "</s>"]
  Underlined text -> T.concat [T.pack "<u>", escapeHtml text, T.pack "</u>"]
  HorizontalRule -> T.pack "<hr />\n"
  Link text url -> T.concat [T.pack "<a href=\"", url, T.pack "\">", escapeHtml text, T.pack "</a>"]
  Image alt url title -> T.concat [T.pack "<img src=\"", url, T.pack "\" alt=\"", alt, T.pack "\"", titleAttr title, T.pack " />"]
  UnorderedList items -> T.concat [T.pack "<ul>\n", T.concat (map renderListItem items), T.pack "</ul>\n"]
  OrderedList items -> T.concat [T.pack "<ol>\n", T.concat (map renderListItem items), T.pack "</ol>\n"]
  CodeBlock text -> T.concat [T.pack "<pre><code>", escapeHtml text, T.pack "</code></pre>\n"]
  InlineCode text -> T.concat [T.pack "<code>", escapeHtml text, T.pack "</code>"]
  PlainText text -> escapeHtml text

renderListItem :: Text -> Text
renderListItem item = T.concat [T.pack "  <li>", escapeHtml item, T.pack "</li>\n"]

titleAttr :: Text -> Text
titleAttr title = if T.null title then T.pack "" else T.concat [T.pack " title=\"", title, T.pack "\""]

escapeHtml :: Text -> Text
escapeHtml =
  T.replace (T.pack "&") (T.pack "&amp;")
    . T.replace (T.pack "<") (T.pack "&lt;")
    . T.replace (T.pack ">") (T.pack "&gt;")
    . T.replace (T.pack "\"") (T.pack "&quot;")
