---
name: magic-hides-complexity
---

# Magic hides complexity

Magical implementations make complex logic appear simple (or opaque) in the surface.
Complexity should be transparent throughout, to help understand it and ideally simplify it.
Complexity should never be hidden.
Code should be explicit in what it does and how.

## Abstractions should not be magical

Abstractions should help keep scope contained, implementations simple and interfaces clear.
Abstractions should not be used to hide complexity away, they should help solve complexity through simple implementations.
Existing abstractions that are magical should be avoided when an explicit alternative exists.

## Side effects are magical

Code with side effects is hard to reason about.
Understanding how a piece of code will execute should be as easy as possible.
Predicting behavior should also be simple.

## Important distinctions live in their expected place

Readers check a known place for each kind of information: what a name holds, what a unit gives back, what a call does.
A distinction written anywhere else is hidden, however short and correct the code.
Prefer the conventional form over an alternative writing that moves the distinction out of its expected place.
