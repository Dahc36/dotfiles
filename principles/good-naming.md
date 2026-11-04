---
name: good-naming
tags: [code, prose]
---

# Good naming

A name is read far more often than it is declared, mostly by someone who will not open the declaration.
It should let that reader go on without looking inside.

## A name says what the thing is here

A placeholder or a single letter only repeats the shape the type already gives.
The name adds what the type cannot: what this value is in this code and what it is for.
Repeating the type in the name adds nothing either; name and type each carry their half.

## Brevity needs context

Brevity is fine when the scope supplies the context, and wrong when it doesn't.
A module, a directory or a type already says part of what the names inside it mean.
Flat listings supply none: each name is read against its siblings, and carries its own context.

## The established term wins

When the reader's ecosystem already has a word for a pattern, that word is the name.
A home-made label for a known pattern sends every reader into the implementation to learn what it is.

## Mechanism is not meaning

A name that says how something works goes stale when the implementation changes and says nothing the caller can rely on.
Name the effect the caller observes and let the implementation stay inside.

## A file name is a name

A file is named in every listing and every import, by someone who will not open it.
Its name says what the file defines, in the same words the code inside uses.
A name the ecosystem reserves for a role promises only that role; code that does more hides behind it.
