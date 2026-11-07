---
name: honest-structure
tags: [code]
---

# Honest structure

A reader infers the parts of a program from its structure before opening a file.
The structure claims what the parts are: one flat listing claims one part.
A part that lives in the author's head is a claim the structure never makes, so every other reader finds one part and reads all of it.
The language has a construct for a part, which the reader sees in the listing and the tools hold the code to; a part drawn in anything else is a claim only its author reads back.

## A name that carries the part marks a missing part

When a file or an identifier needs a prefix to say which part it belongs to, the part has no place of its own.
The prefix works while the listing is short and the author is the reader, and stops working as either changes.
The part the prefix names is drawn with the language's construct, and the prefix is dropped.

## Arguments shared by many signatures are a value nobody declared

When several functions take the same set of values, they are the methods of a thing that has not been declared.
Threading those values through every signature is how the thing is passed around without existing.
Declaring it gives the methods an owner and the signatures their real shape.

## Every thing has one owner

A behavior whose steps are spread over places named for features has no owner.
Each reader reassembles it, and each change to it starts with a search of everything.
The thing is declared in one place, and the features it serves reach it there.
