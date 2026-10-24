---
name: locality-of-behavior
---

# Locality of behavior

Locality is the characteristic of code that enables understanding it by looking at only a small portion of it.
The behavior of a unit of code should be as obvious as possible by inspecting only that unit.

## Separation of concerns and conventions may go against locality

Coding language/tool conventions and traditional separation of concerns may introduce arbitrary separations that go against locality.
In those cases, re-evaluating separations and improving interfaces may help maintain locality.
Locality should not clash with established conventions for the repo or the tools being used.

## Names are declared where the thing is defined

The name the rest of the code uses for a thing belongs on its declaration.
Declaring something under a generic name and giving it its real name only when exposing it, or leaving it nameless so each consumer picks a name, hides what the file defines from anyone reading only that file.
Declare the final name once and expose it under that same name.

## Things are declared where they are used

A value declared far from its only use has to be carried in the reader's head across code that does not need it.
Declare it right before the code that uses it, after any early return that would make it unnecessary.
Gathering declarations at the top of a scope is a habit, not a reason.

## Locality has a size

A unit is local when a reader can hold it whole.
Inlining past that point trades one jump for a scope the reader carries across code that does not need it, and the locality is gone with the indirection.
A named unit declared next to its only use keeps both: the name says what the block does, and the position keeps it in view.
A function passed inline to a call nests its body inside that call; past a few lines, its name says more than the call it is handed to.
