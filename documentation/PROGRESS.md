# Progress - Note Markup Language (jml)

## Design decisions (settled, don't re-litigate)

- A Note holds its content and a list of tags. It can have zero, one, or many tags.

- Tags are separate labels. A note with two tags shows up in both groups, not one combined group.

- Notes with no tag go under "misc" in the flat version. In the tree version they just go at the very top, no fake tag needed.

- In the tree, the first tag you write is the parent, the next one is its child. So @shopping@walmart means walmart sits under shopping.

- The order you write tags in matters and is never changed automatically. @shopping@walmart and @walmart@shopping are treated as two different, unrelated things.

- One tag can have both its own content and its own children at the same time.

- When two notes share a tag, they only get combined if the tag is in the exact same spot in both notes. This check happens one tag at a time as we go deeper into the tree, not by comparing the whole list of tags at once.

- We tried exporting the data as JSON and reading it in JavaScript to build the page, but dropped that. Now Haskell builds the HTML page directly using the lucid library. No extra file in between, no second language involved.

## Done

- Parser (Parser.hs): reads the file line by line, separates the written text from the tags, splits multiple tags apart, and turns each line into a Note.

- First organizer (Organizer.hs): notesToPairs and organizeByTag group notes by tag into one big table (a Map). Right now it only looks at each note's first tag, not all of them.

- HTML page builder (Render.hs): renderNote turns the grouped notes into a page with a heading and a bullet list for each tag. Still being finished.

- Command you run (Main.hs): typing "jml yourfile.jml" reads the file, organizes it, builds the page, saves it as output.html, and opens it in your browser.

- Tree shape (AST.hs): a DocTree is either a tag with a list of things under it, or a piece of content with nothing under it.

- Building the tree (Tree.hs): insertTag adds one note's tags into the tree, one level at a time. mergeTag checks if a tag already exists at that spot and combines the two branches instead of making a duplicate. Tested by hand with the shopping/walmart and shopping/homedepot example and it works.

- buildTree: take the full list of notes and build the whole tree by inserting them one by one. This is the next thing to do. **Definitve**

- trim white space from tag list so you can write @shopping@walmart or @shopping @walmart and its the same thing. The trim removes the front empty space and end empty space. String like " shopping " becomes "shopping"
 

## Next
  
- Decide what should happen when a line is only a tag with no actual text before it, like "@shopping" with nothing written first. Right now this creates a note with empty content, which shows up as a blank line in the page. Need to decide: skip it, warn about it, or treat it some other way.

- Brainstorm new ways to render the notes besides html 
  
- Make the rendered output.html file have a better style

- implement sorting functions to sort alphabetically or choronogically each node
