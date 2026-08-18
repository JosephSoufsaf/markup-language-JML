# Goal and philosophy
The purpose of this language is to optimize the workflow of learning, not document writing. Users capture ideas first and organize them later. The source file remains chronological, while the compiler generates multiple organized views from metadata such as tags and relationships.

# Note(fundemental unit of the language)
A Note is the fundamental unit of the language.
- It contains exactly one idea.
- It is independent of all other notes.
- It may have zero or more tags.
- It may have additional metadata.
- It is never moved after being written.
- Organization is achieved by referencing the note through its tags rather than changing its position in the source file.


# Structure
It follows usual markup languages structure.
- Parses a file
- Based on header information organizes file certain way
- Renders file through HTML directly with haskell
- Main function opens rendered HTML file in browser
