---
name: honest-types
---

# Honest types

A type tells readers and the checker what a value is.
It should only ever say what the value really is, and nothing the code does not guarantee.

## Assertions make a type dishonest

Asserting a type tells the checker to accept something the code has not made true.
From that point on, the type carries no information and the checker stops looking.

## Get the type honestly

Give a value its type through a type argument, a real value of that type, or a check that narrows it.
