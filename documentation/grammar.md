# jml syntax

A `.jml` file is a list of notes, written in the order you think of them. Tags say where each note belongs. The compiler builds the organized views from the tags, and the file itself is never rearranged.

## 1. Notes

A note is **one line**. Write the idea, then its tags at the end of the line.

```
Buy milk @shopping@walmart
Finish the report @todo@work
Just a thought with no tag
```

| Line                         | Text             | Tags               |
| ---------------------------- | ---------------- | ------------------ |
| `Buy milk @shopping@walmart` | `Buy milk`       | shopping > walmart |
| `Just a thought`             | `Just a thought` | none               |

Blank lines are ignored. The text of a note is trimmed.

## 2. Tags

A tag is `@` followed by a **name**. A name is made of letters, digits and `_` (accented letters are fine). Nothing else: no spaces, no `-`, no `.`.

Several tags are written **together, with no spaces**. This is a **chain**, and it reads parent first:

```
@hello@goodbye
@hello_chocolate@goodbye_melon
```

In `@a@b`, `a` is the parent of `b`.

### Where the tags go on a note line

The **last word** of the line is the chain, if it is a valid chain. Everything before it is the text. If the last word is not a valid chain, the whole line is text and the note has no tags.

| Line                             | Text                   | Tags      |
| -------------------------------- | ---------------------- | --------- |
| `something is written @category` | `something is written` | category  |
| `@wow @chocolate`                | `@wow`                 | chocolate |
| `hello @a more text`             | whole line             | none      |
| `bob@example.com`                | whole line             | none      |
| `hello @python`                  | `hello`                | python    |
| `hello @`                        | whole line             | none      |
| `hello @a@`                      | whole line             | none      |
| `hello @well-known`              | whole line             | none      |
| `@a`                             | (empty)                | a         |

An `@` with no name after it is never a tag, so there are no empty tags.

### Writing a literal `@`

To end a note with a literal `@word`, put a backslash before it: `mail bob \@home` gives the text `mail bob @home`.

## 3. Bold and italic

Inside the text of a note:

```
**bold**    *italic*
```

- An opening marker must be followed by a non-space, and a closing marker must be preceded by one.
- A marker that has no match stays as plain text: `2 * 3 * 4` and `price is **5` are not changed.
- Styles do not nest.
- Escapes: `\@`, `\*` and `\\` give a literal `@`, `*` and `\`.

## 4. Blocks of notes

A block gives several notes the same tags, written once. The tags before the `{` are the **path**, parent first.

### One line

Everything between `{` and the last `}` is one note. A chain at the end of the content **continues** the path.

```
@wow@chocolate{hello }
@wow@chocolate{hello @amazing}
@wow{}
```

| Line                             | Text           | Path                      |
| -------------------------------- | -------------- | ------------------------- |
| `@wow@chocolate{hello }`         | `hello`        | wow > chocolate           |
| `@wow@chocolate{hello @amazing}` | `hello`        | wow > chocolate > amazing |
| `@wow{}`                         | (empty note)   | wow                       |
| `@wow{use {x} here}`             | `use {x} here` | wow                       |

### Several lines

Write the opener alone on its line, then the notes, then a closing `}` (it may be indented, and nothing may follow it).

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

Blocks **nest**, and the paths add up. A note inside a block can have its own tags, which continue the path.

Tags written **after** the closing `}` of a notes block are an error. Write the path before the `{`.

## 5. Raw blocks

A raw block holds text that is kept **exactly as written**: blank lines, `#` lines, braces and `@` characters are left alone. Its kind is chosen by a **reserved name**, written as the last tag before the `{`.

| Opener      | The body is                           |
| ----------- | ------------------------------------- |
| `@python{`  | Python code, with syntax highlighting |
| `@math{`    | math                                  |
| `@drawing{` | a Mermaid diagram                     |

Tags can go **before** the opener and **after** the closing `}`. Together they form the path. The reserved name itself is not a tag.

```
@python{x = 1}@coding

@work@python{x = 1}@coding

@python{
def f(x):
    return {"a": x}
}@coding

@drawing{
graph TD
  A-->B
}@diagram
```

| Opener                       | Path          |
| ---------------------------- | ------------- |
| `@python{x = 1}@coding`      | coding        |
| `@work@python{x = 1}@coding` | work > coding |
| `@math{x^2}`                 | none          |

### Where a raw block ends

A raw block ends at the first line that starts with `}` at the **same indentation as the line that opened it** (column 0 for a block at the top level). A `}` that is indented more belongs to the code:

```
@python{
d = {
    'a': 1
    }
x = 2
}@c
```

This is one block. A `}` in column 0 inside the code would end the block early, so write the code indented deeper than the opener if it needs one.

### What the body looks like

- The indentation of the opener is removed from every line.
- Blank lines at the start and at the end are dropped. Blank lines in the middle are kept.
- Raw blocks can sit inside notes blocks.

### The reserved names are only special before a `{`

Everywhere else, `python`, `math` and `drawing` are ordinary tags: `remember this @python` files a note under `python`.

A reserved name must be the **last** tag before the `{`. `@python@code{` and `@python@math{` are errors.

## 6. Headers

Headers choose how the notes are shown. They go at the **top** of the file, before the first note.

```
#view:tree
#sort:chronological
```

| Key    | Values                          | Default        |
| ------ | ------------------------------- | -------------- |
| `view` | `flat`, `tree`                  | `flat`         |
| `sort` | `alphabetical`, `chronological` | `alphabetical` |

- A key or value that is not in the table is an error.
- If a header is repeated, the last one wins.
- A `#view:tree` written after the first note is just text.
- A line like `#view: tree` (with a space) is not a header either.

## 7. The views

- **Flat view:** each note is filed under its **first** tag. Notes with no tag go under `misc`, shown last.
- **Tree view:** each note sits at the end of its **whole** path, so `@a@b` is nested in `a`, then in `b`.
- **Alphabetical:** tags and notes sorted by name or text.
- **Chronological:** tags ordered by their first note, and notes in the order they were written.

## 8. Errors

Every error is reported with its line number, both in the terminal and in a box at the top of the page. An error never stops the compiler: the notes that could be read are still shown.

| Mistake                                               | Example           |
| ----------------------------------------------------- | ----------------- |
| a block that is never closed (reported on its opener) | `@wow{`           |
| a `}` with no open block                              | `}`               |
| a reserved name that is not last                      | `@python@code{x}` |
| tags after the `}` of a notes block                   | `@wow{hi}@b`      |
| an opener whose `{` is never closed on its line       | `@wow{hello`      |
| text after the `}` of a raw block that is not a tag   | `@python{x}foo`   |
| an unknown header key or value                        | `#view:bogus`     |

A raw block that is never closed swallows the rest of the file, because everything after it looks like code.

## 9. A complete example

```
#view:tree
#sort:chronological

Buy milk @shopping@walmart
something is written @category
**Important**: call the bank @todo

@study@haskell{
    Maybe is how you say "this can fail" @types
    @python{
        def safe_head(xs):
            return xs[0] if xs else None
    }@example
}

@drawing{
graph TD
  Idea-->Tag-->View
}@how-it-works
```

(The last tag is a mistake on purpose: `how-it-works` contains `-`, so `}@how-it-works` is not a valid chain, and the compiler reports it on that line.)

## 10. The grammar, formally

```
file         = { header } , { item } ;
header       = "#" , key , ":" , value , EOL ;
item         = blank | note | notes-block | raw-block ;

note         = [ text ] , [ chain ] , EOL ;        (* the chain is the last word *)
chain        = "@" , name , { "@" , name } ;
name         = ( letter | digit | "_" ) , { letter | digit | "_" } ;

notes-block  = one-line | multi-line ;
one-line     = chain , "{" , [ text ] , [ chain ] , "}" , EOL ;
multi-line   = chain , "{" , EOL , { item } , indent , "}" , EOL ;

raw-block    = { "@" , name } , "@" , reserved , "{" , raw-rest ;
raw-rest     = raw-text , "}" , [ chain ] , EOL                      (* one line *)
             | EOL , { raw-line } , same-indent , "}" , [ chain ] , EOL ;
reserved     = "python" | "math" | "drawing" ;
```

## 11. Decisions not made yet

- Should `@Work` and `@work` be the same tag? (Today: no, they differ.)
- Should `-` be allowed in tag names? (Today: no.)
- Should an empty note be drawn as nothing instead of an empty paragraph?
- Should a raw body lose the opener's indentation (today) or the common indentation of its lines?
