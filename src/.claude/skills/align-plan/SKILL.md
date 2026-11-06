---
name: align-plan
description: Carve the next step out of a plan file, align with me on what building it needs, and leave it as an alignment.md for /align-build. Only when I invoke it; never on your own initiative.
argument-hint: '[plan file, default plan.md]'
disable-model-invocation: true
---

Carve one step out of the plan at `$ARGUMENTS`, align with me on what building it needs, and leave an `alignment.md` for `/align-build` at the root of the step's repo.

`/align` is a process for writing `alignment.md`, a list of facts and agreed decisions.
A plan is an `alignment.md` too big to build directly.

`$ARGUMENTS` is the plan's path. Empty means `plan.md` at the root of the opened project; when that does not exist either, ask me which file.

Nothing is built. The only files written are `alignment.md` and the plan, both following my prose principles. Neither is committed, and `.gitignore` is not touched.

## The step

Propose one step with its reason, and I accept it or name another.
Foundations other steps depend on come first, then the smallest step that closes whole decisions.

Propose the step's repo root from the plan too; I confirm it as one more decision.
When the root does not exist, create the folder and nothing more: whatever the repo needs, `git init` included, is the step's own work.

## alignment.md

An ordinary `alignment.md`: title, facts and decisions, with no mention of the plan.
Written next to the plan, updated after every exchange, and moved to the step's repo root at wrap-up.

The step's decisions seed it as settled.
Its last decision is how the step ships, as in `/align`: seeded from the plan when it says how, asked in the interview otherwise.

A plan fact goes where it is still needed:

- to `alignment.md` when the step's work needs it
- stays in the plan when a remaining step needs it
- in both when both need it
- dropped when nothing needs it anymore

## The interview

An `/align` interview on what the step's plan decisions leave out: the details a plan overlooks and building the step still needs. Its rules are `/align`'s:

- one question at a time, with a recommended answer
- facts looked up, decisions mine

A plan decision is reopened only when a surfaced detail contradicts it, and is then rewritten.

## The plan at wrap-up

Rewritten as `/align-build` rewrites `alignment.md` after a commit:

- the step's decisions and the facts only it needs are removed
- a later decision a surfaced detail changes is rewritten, never annotated
- the remaining decisions are numbered from 1 again, and every reference to a decision number is updated
- nothing about progress is added
- a plan with nothing left is deleted, and the skill says so

## Process

1. Resolve the plan from `$ARGUMENTS`, asking when needed. Stop and say so, touching nothing, if either holds:
   - the plan file does not exist
   - an `alignment.md` already exists next to it
2. Read every file printed by `aiprinciples prose`, then the plan.
3. Propose the step and its repo root; I decide.
4. Seed `alignment.md` with the step's facts and decisions, then interview until I confirm shared understanding.
5. Rewrite the plan, deleting it when nothing is left.
6. Create the repo root when it does not exist, and move `alignment.md` there.
7. End with one line and an offer:
   - the line names the step, where `alignment.md` went and what changed in the plan
   - the offer is to commit alignment.md in the repo with a version of "align: <short headline>" that matches the repo's conventions.
