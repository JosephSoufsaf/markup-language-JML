# Progress - Note Markup Language 

## Design decisions

- A Note holds its content and a list of tags. It can have zero, one, or many tags.

- Tags are separate labels. A note with two tags shows up in both groups, not one combined group.

- Notes with no tag go under "misc" in the flat version. In the tree version they just go at the very top, no fake tag needed.

- In the tree, the first tag you write is the parent, the next one is its child. So @shopping@walmart means walmart sits under shopping.

- The order you write tags in matters and is never changed automatically. @shopping@walmart and @walmart@shopping are treated as two different, unrelated things.

- One tag can have both its own content and its own children at the same time.

- When two notes share a tag, they only get combined if the tag is in the exact same spot in both notes. This check happens one tag at a time as we go deeper into the tree, not by comparing the whole list of tags at once.

- We tried exporting the data as JSON and reading it in JavaScript to build the page, but dropped that. Now Haskell builds the HTML page directly using the lucid library. No extra file in between, no second language involved.

## Done

- 

## Next

- add a way to easily create graph drawings for making figures easily 

- add a way to like make a bunch of notes go under one tag with the same sort of syntax as a comment
  
- Add a way to link different files. To create links

- Determine a way to seperate special tag blocks. Parse them as Content algebraic or create a new algebraic data type for them

- Determine how to handle giving tags to the special tag blocks. At the end of the block (@python{}@hello) or at the start after the special tag block (@python@hello{})

