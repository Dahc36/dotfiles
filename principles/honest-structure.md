---
name: honest-structure
tags: [code]
---

# Honest structure

A reader infers the parts of a program from its structure before opening a file.
The structure draws the boundaries between them: one flat listing draws none, and claims one part.
A boundary that lives in the author's head is one the structure never draws, so every other reader finds one part and reads all of it.
The language has a construct for drawing a boundary, which the reader sees in the listing and the tools hold the code to; a boundary drawn in anything else is one only its author reads back.

## A prefix is a boundary the structure does not draw

When a file or an identifier needs a prefix to say which part it belongs to, the part has no place of its own.
The prefix works while the listing is short and the author is the reader, and stops working as either changes.
The boundary the prefix implies is drawn with the language's construct, and the prefix is dropped.

## Arguments shared by many signatures are a value nobody declared

When several functions take the same set of values, they are the methods of a thing that has not been declared.
Threading those values through every signature is how the thing is passed around without existing.
Declaring it gives the methods an owner and the signatures their real shape.

## Every thing has one owner

A behavior whose steps are spread over places named for features has no owner.
Each reader reassembles it, and each change to it starts with a search of everything.
The thing is declared in one place, and the features it serves reach it there.
