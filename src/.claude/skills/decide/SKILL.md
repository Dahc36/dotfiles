---
name: decide
description: Make one choice by applying all of my decision principles with judgment, and return it with its reason. Only when I invoke it, or when another skill delegates to it; never on your own initiative.
argument-hint: '[the question and what was found]'
---

Make one choice by applying my decision principles.

It only decides:

- it edits nothing
- it asks me nothing
- recording the choice is the caller's work

## Principles

Read every file printed by `aiprinciples decision`, fresh on every call. Each one describes a principle I want my decisions to follow and the reasoning behind it.

These are broad guidelines, not rules.
Apply them with nuance, in the context of the question.
Understand the reasoning behind each principle and let it weigh only where it bears on this particular choice.
Never apply a principle mechanically.

## The question

The question and what was found come from `$ARGUMENTS`, or from the skill that delegated here.
With neither, say so and stop.

## Process

1. Pin down the question, and read what it points at with enough context to understand it.
2. Lay out the options that are really open, including any the caller did not name.
3. Read the principles.
4. Weigh each option against them and choose.
5. Return:
   - the choice, in one line
   - its reason
   - whether the principles settled it, by pointing clearly at one option, or left it open
     1. NOTE: a choice is returned either way
