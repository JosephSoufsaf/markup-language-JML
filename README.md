# Goal and philosophy

The purpose of this language is to optimize the workflow of learning, not document writing. Users capture ideas first and organize them later. The source file remains chronological, while the compiler generates multiple organized views from metadata such as tags and relationships.

# Note (fundamental unit of the language)

A Note is the fundamental unit of the language.

- It contains exactly one idea.
- It is independent of all other notes.
- It may have zero or more tags.
- It may have additional metadata.
- It is never moved after being written.
- Organization is achieved by referencing the note through its tags rather than changing its position in the source file.

# Structure

It follows the usual markup language structure.

- Parses a file into notes.
- Organizes the notes into different views (currently a flat view grouped by tag, and a tree view nested by tag).
- Renders each view directly to HTML with Haskell, no intermediate file or second language involved.
- The main program opens the rendered HTML file in the browser.

Picking which view gets shown, or how it's organized, from settings written at the top of a file is planned but not built yet. Right now both views are always rendered together on the same page.

# How to use it

Write a plain text file with one note per line. Add a tag to a note by writing @ followed by the tag name, right after the note's text. A note can have more than one tag by writing more @tags right after each other, with no space between them. A note with no @ at all is untagged.

```
Buy milk @shopping@walmart
Finish the report @todo@work
Just a thought with no tag
```

Save the file with a .jml extension, for example notes.jml. The extension is just a naming convention, the parser doesn't check it.

Compile the project. This produces an executable named jml (jml.exe on Windows). Run it from the same folder, giving it your file:

```
jml.exe notes.jml
```

This reads notes.jml, organizes the notes, writes the result to output.html, and opens it in your default browser automatically. Each tag section is collapsible, click it to expand or hide its contents. 

Running it by name from any folder currently requires adding it to your PATH environment variable yourself. An installer that does this automatically is planned but not built yet.


# How organization works

Right now the program builds two different views of your notes from the same file, and shows both.

Flat view: every tag becomes its own group. If a note has more than one tag, only the first one is used to decide where it goes. Notes with no tag at all go into a group called "misc" at the end. Groups are shown alphabetically.

Tree view: tags are nested inside each other based on the order you wrote them. The first tag on a note is treated as the outer, more general one, and each tag after it is nested one level deeper, inside the one before it. For example, a note written as @shopping@walmart puts it under shopping, and inside that, under walmart. If two notes share the same tag at the same level, they get combined into one branch instead of showing up twice. A tag can have both its own notes and further tags nested under it at the same time. Notes with no tag at all sit at the very top level, not nested under anything. The order tags are written in matters, @shopping@walmart and @walmart@shopping are treated as two different, unrelated branches.

Each group or branch appears as a collapsible section you can click to expand or hide.

This reads notes.jml, organizes the notes, writes the result to output.html, and opens it in your default browser automatically. Each tag section is collapsible, click it to expand or hide its contents.
