---
name: brainstorm
description: Put words to a problem I only sense, gather every option for it, then narrow them to the one idea worth exploring deeply, in idea.md.
argument-hint: '[the problem, as vague as it is]'
disable-model-invocation: true
---

Brainstorm with me, from a vague feeling that something is off to the one idea worth exploring deeply. The problem is `$ARGUMENTS`; when empty, ask me what it is.

Two things matter equally: putting words to the feeling until the underlying problem is found, and coming up with lots of options for it before narrowing them to one.
Breadth over depth: `idea.md` stays light.

Questions come one at a time, each with your recommended answer.
Facts you can look up, look up: code, config and local manuals first, online docs when those run out.
Decisions are mine.
Nothing is modified; the only file written is `idea.md`.

## idea.md

Written at the root of the opened project, never committed, and `.gitignore` is not touched.
It is our shared state, updated after every exchange that changes something.
Read every file printed by `aiprinciples prose` before the first write and follow them on every update.

An existing `idea.md` is resumed: read it, say in one line where it stands, and continue in its current stage.
One that already has `## Idea` is complete: say so and ask whether to reopen it.

### Problem

`## Problem` holds:

- the problem being brainstormed, first
- constraints: known limitations and related problems any option must live with, one line each
- problems for later: surfaced problems that neither are the one being solved nor constrain it, one line each

The three are fluid: a problem for later becomes the problem or a constraint as understanding grows, and the reverse.

### Options

`## Options` holds one item per option ever considered, its details as one-line sub-items with a prefix:

- `INFO` what it entails
- `PRO`
- `CON`
- `OUT` why it was ruled out
- `Q` an open question that would decide it

Add a prefix when a category earns one. No cap on sub-items: the depth is what it takes to compare the options with each other.

### Idea

`## Idea` is written only when one option stands:

- the winning option, and in one line why it won over the closest runners-up
- the nuance learned: the constraints that decided it, the `Q` lines still open, what to look at first when exploring it deeply

`## Options` stays in full, every `OUT` included, as the record of the reasoning.

## Process

1. Interview me, one question at a time, as long as it takes to articulate the problem.
   1. Ends when the problem is stated in `## Problem`.
2. Breadth: gather every option.
   1. Propose options in batches, each batch varied in angle: do nothing, buy versus build, change the process not the tool, extreme, minimal, another field's answer.
   2. After each batch I react and add my own; everything goes to `## Options`.
      NOTE: a new option must be distinct from every listed one, or it merges into the one it resembles.
   3. Ends when a round adds nothing distinct and I agree the list is complete.
3. Narrowing: eliminate options until one stands.
   1. Ask what I want, one question at a time with a recommended answer, each chosen to eliminate or split the most options.
   2. My answer becomes a constraint in `## Problem`; the options it kills get an `OUT` line with the reason.
      NOTE: I rule out, you propose.
   3. Close options get the `PRO` and `CON` lines that separate them.
   4. Ask a `Q` only when neither of us can answer without looking it up, then look it up.
   5. When narrowing sharpens the problem, go back to step 2 against the new definition, for new options, variations or amendments of listed ones.
   6. Ends when one option stands.
4. Write `## Idea`.
5. End by offering `/align` as the next step, with `idea.md` as its input.
   1. `idea.md` stays; never offer to remove it.
