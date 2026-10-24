---
name: documentation-is-a-liability
---

# Documentation is a liability

Documentation is prose about the code.
Nothing checks it, nothing runs it, and no test fails when it stops being true.
It drifts as the code moves, and it drifts faster the further it lives from the code it describes.

## Documentation earns its place by saying what the code cannot

A line of documentation is justified only for what code, names, types and tests cannot say.
What a reader would learn by opening the code it describes is a second copy, and the copy is the one that goes stale.

## The place a sentence lives in does not justify it

The same sentence is not more justified in a README than next to the code.
A line that would be deleted as a comment is deleted as documentation too; see [[comments-are-a-liability]] for that judgment.
