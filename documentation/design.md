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
1. Read document content
2. Parser turns content into list with appropriate data types
3. Organizer rearranges result of parser in different ways that will each be rendered differently. 

# Organizer
As mentionned the organizer has will organize views in different ways that will permit the renderer to display content in different ways

## View n°1 (Group view)
This is the view that was in mind when the language was being created