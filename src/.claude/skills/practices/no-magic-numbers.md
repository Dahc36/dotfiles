---
name: no-magic-numbers
---

# No magic numbers

Magic numbers are hard to maintain.
We should prefer named constants or variables that make values explicit.
This applies to all types of values (not just numbers), even a string (although the string itself may be descriptive) could be "magical".

There can be exceptions where meaning is obvious in context (e.g. `items.length === 0`).
This practice should not make code harder to read, prefer defining literals close to their usage.
