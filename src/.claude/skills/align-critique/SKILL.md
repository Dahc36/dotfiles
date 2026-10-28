---
name: align-critique
description: Pressure test the plan in alignment.md to find its faults, then settle each one with me. Only when I invoke it; never on your own initiative.
disable-model-invocation: true
---

Pressure test the plan in `alignment.md` so that a poorly constructed idea does not progress. Find its faults, keep only the ones that hold up to scrutiny, then settle each one with me.

`alignment.md` is the output of `/align`: a short list of facts and agreed decisions, at the root of the opened project. Takes no arguments.

Nothing is built. The only files ever written are `critique.md` and `alignment.md`, both following my `documenting` principle.

## Problems

A problem is a fault in the plan: what breaks, and for whom, if the plan goes ahead as written. "Consider edge cases" is not a problem; "the migration in decision 4 locks the table, and checkout stalls while it runs" is.

The plan is assumed wrong until it survives. Attack it from every angle that could show a fault. These are illustrations, not a list; the test is whether the plan has a fault, not whether an angle is named here:

- the premise: the problem it solves is not real, or the goal is not worth having
- an assumption stated as a fact and never checked
- feasibility: it cannot be built as described, in this codebase, with these tools
- a case it does not handle, or what happens when it fails
- cost, reversibility, and a simpler alternative that gets the same result
- a contradiction between two decisions, or between the plan and the code

Be generous at this stage: scrutiny prunes. No praise, and no verdict on the plan as a whole.

## critique.md

Written at the root of the project, never committed, and `.gitignore` is not touched. One block per problem:

- a header line, `## <number>. <title>`
- what breaks and for whom
- once scrutinized: the evidence, the consequence for the plan, and an `Unsettled:` line with the question only I can answer, when there is one

## Scrutiny

Each problem goes to a fresh subagent, through the Agent tool, that has not seen the other problems and whose job is to kill this one. It gets `alignment.md`, the one problem, and these bounds:

- It may read the project and its installed dependencies, local manuals and online docs, and run throwaway experiments that leave the working tree as it found it.
- It never edits project files, never runs the project's checks, and never touches `alignment.md` or `critique.md`.
- It returns one verdict, which decides the problem's fate:
  - refuted, with the evidence: dropped
  - holds, with the evidence and the concrete consequence for the plan: kept
  - needs me, with the question and all the evidence I need to decide it: kept, as unsettled
    NOTE: only when the answer sits with me. Everything that could be looked up or tried has been.

Subagents run in parallel.

## Walkthrough

As `/align` does: one problem at a time, with a recommended answer, waiting for mine before the next. Each problem ends in one of three ways:

1. We agree it does not apply.
2. We agree it applies: propose the exact change to `alignment.md`, a new fact or decision or a rewritten one, with a recommended answer, and I decide.
   NOTE: a changed decision is rewritten, never annotated. `alignment.md` always reads as a plan, never as a history.
3. We agree it fundamentally breaks the plan: delete `critique.md` and `alignment.md`, say so and stop.

After 1 or 2 the problem is removed from `critique.md`.

## Process

1. Stop and say so, touching nothing, if either holds:
   - there is no `alignment.md` at the root of the project
   - a `critique.md` already exists at the root of the project
2. Read `documenting.md` from my principles (`~/.claude/skills/principles/documenting.md`), then `alignment.md`, then whatever code and docs the plan concerns, enough to tell its facts from its assumptions.
3. Write the problems to `critique.md`.
4. Scrutinize every problem, then rewrite `critique.md` with only the survivors, renumbered, each with its evidence and consequence. If none survive, say so, delete `critique.md` and stop.
5. Apply `documenting.md` to `critique.md`.
6. Walk through the survivors, applying `documenting.md` to `alignment.md` after each change to it. Delete `critique.md` once it is empty.
7. End with one line: what was agreed, what was dismissed, and what changed in `alignment.md`.
