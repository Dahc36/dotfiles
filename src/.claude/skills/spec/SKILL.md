---
name: spec
description: Write the tech spec from alignment.md, settling the detail the build needs, and leave it for /spec-build.
disable-model-invocation: true
---

Write the tech spec of the work agreed in `alignment.md`, so that `/spec-build` can build all of it without me.

`alignment.md` is the output of `/align`: a short list of facts and agreed decisions, at the root of the opened project.
The spec replaces it.
Do not reopen the decisions in it.

Nothing is built or committed, and no branch is created: the spec's first commit is `/spec-build`'s.

## The spec

A tech spec, which owes nothing to the shape of `alignment.md`.
It follows my prose principles, the files printed by `aiprinciples prose`.

Its sections are those of a conventional design doc, in this order:

1. `Context`: why the work exists, and the facts the design relies on.
2. `Goals`.
3. `Non-goals`: they bound what `/spec-build` may choose to build when the spec turns out wrong or silent.
4. `Design`: how it will work, each decision with its reason, in whatever sub-sections fit the work.
5. `Plan`: the ordered breakdown of what needs to happen for the parts agreed in `Design` to be in place.
   - Each step states the checks that prove it is done.
   - It says nothing about commits or PRs: cutting the work into them is `/spec-build`'s.
6. `Changelog`: empty, for `/spec-build` to append to.

The spec is committed and stays in the repo after the work merges, so it carries:

- no mark of which steps are done: the code and each step's checks say that
- no creation or edit date: git holds both

## The detail

`alignment.md` leaves open details the build needs. List them, then settle each before writing:

1. Look up whatever is a fact.
2. Invoke the `decide` skill through the Skill tool, with the question and what was found.
3. When the principles settled it, the choice goes into the spec.
   - State it to me with its reason, and carry on.
4. When they left it open, ask me, with the choice as your recommendation, saying the principles did not settle it.
   - One question at a time, waiting for my answer before the next.

## The file

Settled last, once the detail is: a name chosen before the work is understood is a premature one.
Ask me where the spec is created, and propose its name with the question.

The name is the work's own, never a generic one like `spec.md`.
Without its extension it is the prefix of every branch of the run, as `specbranch <spec path>` prints it.
Propose another name when either holds:

- a file already exists at that path
- `specbranch --list <spec path>` prints a branch: that prefix belongs to another run

## Process

1. If there is no `alignment.md` at the root of the opened project, say so and stop.
2. Read every file printed by `aiprinciples prose`, then `alignment.md` and the code it concerns.
3. Settle the detail.
4. Settle the file's place and name.
5. Write the spec.
6. Check that the spec resolves every fact and decision of `alignment.md`, and name any it does not.
   - Resolve each with me, then check again.
7. Remove `alignment.md` once nothing is left unresolved.
8. End by naming the spec's path, and `/spec-build <spec path>` as the next step.
