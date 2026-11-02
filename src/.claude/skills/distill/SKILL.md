---
name: distill
description: Shorten a text file as far as it goes without losing its essence, one line at a time, every cut checked by a judge that has not seen the edits.
argument-hint: '[file path]'
disable-model-invocation: true
---

Shorten the file at `$ARGUMENTS` as far as it goes without losing its essence.

The file is edited in place, in one unattended run. Nothing is committed.

Empty `$ARGUMENTS`: ask which file.

## What is distilled

Paragraphs, headings, list items and table cells. A table is re-aligned after its cells change.

Left verbatim: fenced code blocks, inline code, frontmatter, URLs and blank lines.

The file's language is kept.

## Essence

The essence of a file is its crucial details.
A detail is crucial when a reader without it would do, decide or understand something differently.

- Crucial: a fact, a constraint, a step, a condition, a name.
- Not crucial: tone, emphasis, hedges, and examples that repeat a stated rule.

## The judge

After each cut, a fresh subagent that has seen no edit reads the scratchpad copy of the original and the current file, and answers one of two:

- same essence
- which crucial detail was lost

Readability is this session's call; essence is the judge's.

## A line

Every line goes through the same loop:

1. Divide, following `documenting.md`: each idea gets its own line, nested under the line it belongs to.
   1. Every new line then goes through this loop itself.
2. Shorten: cut to a shorter version that reads as well or better.
   1. A line that repeats another or carries nothing crucial is cut to nothing.
   2. A removed heading takes its section's lines up one level.
3. Judge the cut.
   1. Same essence: keep it and shorten again.
   2. A detail lost: undo the cut and try one more that keeps the named detail.
      1. A second rejection ends the line as it stood before the failed cut.
4. The line is done when no shorter version comes up that reads as well or better.

The files printed by `aiprinciples prose` bind every cut: a shorter line that breaks a principle is not made.

## Process

1. Read every file printed by `aiprinciples prose`.
2. Save a copy of the original in the scratchpad.
3. Walk the lines top to bottom, each through the loop above.
4. End with one line: lines before and after, characters saved, and how many cuts the judge rejected.
