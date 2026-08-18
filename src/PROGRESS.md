# Progress - Note Markup Language (jml)

## Design decisions (settled, don't re-litigate)

A Note holds its content and a list of tags. It can have zero, one, or many tags.

Tags are separate labels. A note with two tags shows up in both groups, not one combined group.

Notes with no tag go under "misc" in the flat version. In the tree version they just go at the very top, no fake tag needed.

In the tree, the first tag you write is the parent, the next one is its child. So @shopping@walmart means walmart sits under shopping.

The order you write tags in matters and is never changed automatically. @shopping@walmart and @walmart@shopping are treated as two different, unrelated things.

One tag can have both its own content and its own children at the same time.

When two notes share a tag, they only get combined if the tag is in the exact same spot in both notes. This check happens one tag at a time as we go deeper into the tree, not by comparing the whole list of tags at once.

We tried exporting the data as JSON and reading it in JavaScript to build the page, but dropped that. Now Haskell builds the HTML page directly using the lucid library. No extra file in between, no second language involved.

## Done

Parser (Parser.hs): reads the file line by line, separates the written text from the tags, splits multiple tags apart, and turns each line into a Note.

First organizer (Organizer.hs): notesToPairs and organizeByTag group notes by tag into one big table (a Map). Right now it only looks at each note's first tag, not all of them.

HTML page builder (Render.hs): renderNote turns the grouped notes into a page with a heading and a bullet list for each tag. Still being finished.

Command you run (Main.hs): typing "jml yourfile.jml" reads the file, organizes it, builds the page, saves it as output.html, and opens it in your browser.

Tree shape (AST.hs): a DocTree is either a tag with a list of things under it, or a piece of content with nothing under it.

Building the tree (Tree.hs): insertTag adds one note's tags into the tree, one level at a time. mergeTag checks if a tag already exists at that spot and combines the two branches instead of making a duplicate. Tested by hand with the shopping/walmart and shopping/homedepot example and it works.

## Next

1. buildTree: take the full list of notes and build the whole tree by inserting them one by one. This is the next thing to do. **Definitve**
 
2. renderTree: turn the tree into an HTML page, similar to what renderNote does now but showing the real nesting. **Uncertain**

3. Hook the tree version into Main.hs alongside the current flat version. Still need to decide how you pick which one shows up. **Uncertain**

4. Add a way to write settings at the top of a .jml file, like #order or #group, to choose how notes get organized. This waits until the tree version is hooked up. **Uncertain**

5. Add ways to sort the flat version: alphabetically (already close to working) and by the order notes were written (harder, since the Map doesn't remember order - we already ran into this with the misc tag). **Uncertain**

6. Come back to making every tag on a note count, not just the first one. **Uncertain**

7. Make the HTML page actually look nice. Right now it works but looks plain. Once it looks good, set it up so you can run "jml" from any folder. **Uncertain**