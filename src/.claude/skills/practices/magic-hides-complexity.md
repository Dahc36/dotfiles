---
name: magic-hides-complexity
---

# Magic hides complexity

Code should be explicit in what it does and how.

## Abstractions should not be magical

Abstractions should help keep scope contained, implementations simple and interfaces clear.
Abstractions should not be used to hide complexity away, they should help solve complexity through simple implementations.

## Side effects are magical

Code with side effects is hard to reason about.
Understanding how a piece of code will execute should be as easy as possible.
Predicting behavior should also be simple.
