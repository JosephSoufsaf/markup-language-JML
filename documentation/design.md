# Syntax and grammar

> **Status:** this is the specification the parser is being rewritten to
> match. Parts of it (blocks with tag paths, nesting, escapes, error
> messages) are not implemented yet.

## Core idea

A note is one idea on one line. Tags say where the note belongs. Blocks
exist only as shorthand for giving several notes the same tags: every note
inside a block is still an independent note, and nothing is ever moved in
the source file.

## Words and names

- A **name** is one or more letters, digits or `_`. Names are case-sensitive.
  `-` is not allowed, so `@well-known` is not a tag. **(proposed)**
- A **chain** is one or more `@name` written with no spaces:
  `@hello@goodbye`, `@hello_chocolate@goodbye_melon`.
  A chain reads parent first: in `@a@b`, `a` is the parent of `b`.
- A bare `@` or `@@` is never a tag, so empty tags cannot exist.
- The **reserved names** are `python`, `math` and `drawing`. They have a
  special meaning only as the last tag before a `{` (see Raw blocks).
  Anywhere else they are ordinary tags: `remember this @python` files the
  note under `python`.
- Line endings (LF or CRLF) are normalised once, before parsing.

## Headers

Headers set how the file is displayed. They are only valid at the top of
the file, before the first note.

```
#view:tree
#sort:chronological
```

| Key    | Values                          | Default        |
| ------ | ------------------------------- | -------------- |
| `view` | `flat`, `tree`                  | `flat`         |
| `sort` | `alphabetical`, `chronological` | `alphabetical` |

An unknown key or value is an error. If a header is repeated, the last one
wins. **(proposed)** After the first note, a line like `#view:tree` is just
text.

## Notes

A note is one line. The **last word** of the line is the tag chain if it is
a valid chain. Everything before it is the note's text. If the last word is
not a chain, the whole line is text and the note has no tags.

```
Buy milk @shopping@walmart        text "Buy milk",               tags shopping > walmart
something is written @category    text "something is written",   tags category
@wow @chocolate                   text "@wow",                   tags chocolate
hello @a more text                text "hello @a more text",     no tags
bob@example.com                   text "bob@example.com",        no tags
hello @python                     text "hello",                  tags python
Just a thought                    no tags
```

A literal `@word` at the end of a note is written `\@word`.

## Bold and italic

Inside note text:

- `**bold**` and `*italic*`.
- An opening marker must be followed by a non-space and a closing marker
  must be preceded by one. An unmatched marker is literal text, so
  `2 * 3 * 4` and `a * b` stay as written.
- Styles do not nest (yet).
- Escapes: `\*`, `\@` and `\\`.

## Notes blocks

A notes block gives the notes inside it a shared tag path. The tags written
before the `{` are the path; they come first, parent first.

**One line.** Everything between `{` and the final `}` is one note. A chain
at the end of the content continues the path.

```
@wow@chocolate{hello }              hello  ->  wow > chocolate
@wow@chocolate{hello @amazing}      hello  ->  wow > chocolate > amazing
@wow{}                              an empty note  ->  wow
```

**Multi-line.** The opener is alone on its line, then notes, then a closer
`}` (indentation allowed, nothing after it).

```
@wow{
    first idea
    @chocolate{
        second idea @amazing
    }
}
```

| Note        | Path                      |
| ----------- | ------------------------- |
| first idea  | wow                       |
| second idea | wow > chocolate > amazing |

Blocks nest, and their paths concatenate. Tags after the closer of a notes
block are an error: the path is written in front of the `{`. **(proposed)**

## Raw blocks

A raw block holds text that is kept exactly as written: blank lines, `#`
lines, braces and `@` characters are all left alone. The kind is chosen by
a reserved name written last in the opener:

| Opener      | Body is                          |
| ----------- | -------------------------------- |
| `@python{`  | Python code (syntax highlighted) |
| `@math{`    | math                             |
| `@drawing{` | a Mermaid diagram                |

Tags can be written before the opener and after the closer; together they
form the path. The reserved name is not a tag.

```
@python{x = 1}@coding              one line;      tags coding
@work@python{x = 1}@coding         tags work > coding

@python{
def f(x):
    return {"a": x}
}@coding                           multi-line;    tags coding
```

The closer is a `}` at the same indentation as its opener (column 0 for a
top-level block), followed directly by an optional chain. A `}` indented
deeper belongs to the code. When a raw block sits inside an indented notes
block, the opener's indentation is removed from the body. **(proposed)**

A reserved name must be the last tag before the `{`: `@python@code{` and
`@python@math{` are errors.

## Errors

Every error reports a line number.

- a block that is never closed (reported at its opener)
- a stray `}` with no open block
- a reserved name that is not last in an opener
- tags after the closer of a notes block
- a malformed opener, such as `@wow{hello` with no closing `}`
- an unknown header key or value

## Formal grammar

```
file         = { header } , { item } ;
header       = "#" , key , ":" , value , EOL ;
item         = blank | note | notes-block | raw-block ;

note         = [ text ] , [ chain ] , EOL ;      (* chain must be the last word *)
chain        = "@" , name , { "@" , name } ;
name         = ( letter | digit | "_" ) , { letter | digit | "_" } ;

notes-block  = one-line | multi-line ;
one-line     = chain , "{" , [ text ] , [ chain ] , "}" , EOL ;
multi-line   = chain , "{" , EOL , { item } , indent , "}" , EOL ;

raw-block    = { "@" , name } , "@" , reserved , "{" , raw-rest ;
raw-rest     = raw-text , "}" , [ chain ] , EOL                       (* one line *)
             | EOL , { raw-line } , same-indent , "}" , [ chain ] , EOL ;
reserved     = "python" | "math" | "drawing" ;
```

## Examples and their results

| Input                            | Result                                   |
| -------------------------------- | ---------------------------------------- |
| `Buy milk @shopping@walmart`     | text `Buy milk`; path shopping > walmart |
| `@wow @chocolate`                | text `@wow`; path chocolate              |
| `bob@example.com`                | text only, no tags                       |
| `hello @python`                  | path python (ordinary tag)               |
| `@wow@chocolate{hello @amazing}` | `hello`; path wow > chocolate > amazing  |
| `@python{x=1}@c`                 | raw python `x=1`; path c                 |
| `@work@python{x=1}@c`            | raw python `x=1`; path work > c          |
| `@python@code{x=1}`              | error: reserved name not last            |
| `@wow{hi}@b`                     | error: tags after a notes-block closer   |
| `}` on its own                   | error: stray `}`                         |
| `@wow{` never closed             | error at the opener's line               |

## Open decisions

- Case-insensitive tags (`@Work` = `@work`)? Currently no.
- Allow `-` in names? Currently no.
- Should an empty note render as nothing instead of an empty paragraph?
