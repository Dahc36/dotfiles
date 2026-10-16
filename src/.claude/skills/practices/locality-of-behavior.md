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
