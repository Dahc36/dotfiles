---
name: honest-structure
tags: [code]
---

# Honest structure

A reader infers the parts of a program from its structure before opening a file.
The structure draws the boundaries between them: one flat listing draws none, and claims one part.
A boundary that lives in the author's head is one the structure never draws, so every other reader finds one part and reads all of it.
The language has a construct for drawing a boundary, which the reader sees in the listing and the tools hold the code to; a boundary drawn in anything else is one only its author reads back.

## A prefix that spreads is a boundary waiting to be drawn

A prefix says which part a file or an identifier belongs to, and on a few names it is the cheapest way to say it.
It works while the listing is short and the author is the reader, and stops working as either changes.
Once many names share it, they are a part with no place of its own.
That is when the boundary is drawn with the language's construct, and the prefix is dropped.

## Arguments shared by many signatures are a value nobody declared

When several functions take the same set of values, they are the methods of a thing that has not been declared.
Threading those values through every signature is how the thing is passed around without existing.
Declaring it gives the methods an owner and the signatures their real shape.

## Every thing has one owner

A behavior whose steps are spread over places named for features has no owner.
Each reader reassembles it, and each change to it starts with a search of everything.
The thing is declared in one place, and the features it serves reach it there.
