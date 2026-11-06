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
A detail is crucial when a reader without it would do or decide something differently, or take a different fact away.
How a detail is worded, stressed, framed or motivated is not a detail of its own.

- Crucial: a fact, a constraint, a step, a condition, a name.
- Not crucial: tone, emphasis, hedges, rationale that changes no decision, and examples that repeat a stated rule.

## The judge

After each cut, a fresh subagent that has seen no edit reads the scratchpad copy of the original and the current file.
It is given the essence section above and answers with one line:

- same essence
- lost: the detail, and what a reader of the current file would do or decide differently, or which fact they would take away differently.

A loss the judge cannot tie to such a consequence is not a loss, and the answer is "same essence".
A detail the current file still states anywhere is not lost.

The judge decides only whether the essence is kept.
Whether the cut reads well is decided here, before the judge sees it.

## A line

Every line goes through the same loop:

1. Divide, following `documenting.md`: each idea gets its own line, nested under the line it belongs to.
   1. Every new line then goes through this loop itself.
2. Shorten: cut to a shorter version that reads as well or better, climbing three rungs of ambition.
   1. Words: drop descriptors, adjectives, adverbs, superlatives and hedges, or rewrite the line without them.
   2. Phrasing: say the same ideas in fewer words.
   3. Ideas: remove an idea the reader does not need.
      1. A line that repeats another or carries nothing crucial is cut to nothing.
      2. A removed heading takes its section's lines up one level.
   4. A rung is left for the next only when it yields no shorter version that reads as well or better.
3. Judge the cut.
   1. Same essence: keep it and shorten again on the same rung.
   2. A detail lost: undo the cut and try one more on the same rung that keeps the named detail.
      1. A second rejection ends the rung as the line stood before the failed cut; on the last rung it ends the line.
4. The line is done when the last rung yields no shorter version that reads as well or better.

The files printed by `aiprinciples prose` bind every cut: a shorter line that breaks a principle is not made.

## Process

1. Read every file printed by `aiprinciples prose`.
2. Save a copy of the original in the scratchpad.
3. Walk the lines top to bottom, each through the loop above.
4. End with one line: lines before and after, characters saved, and how many cuts the judge rejected.
