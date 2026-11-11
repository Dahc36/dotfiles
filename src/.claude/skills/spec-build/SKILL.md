---
name: spec-build
description: Build the whole tech spec unattended, one commit at a time, onto one local branch per PR.
argument-hint: '[spec path]'
disable-model-invocation: true
---

Build everything the spec asks for, without me: every commit made, on one local branch per PR.

The spec is the output of `/spec`.
I review the branches afterwards, so nothing waits for me during the run.

- Refusing to start is the only stop.
  - Past it, the run asks me nothing.
- Nothing is pushed or posted: opening each PR is mine.
- Commits are never deleted and branches never moved back.

## The run

The spec's path is `$ARGUMENTS`; when empty, ask which file.

The branches of a run carry a prefix taken from the spec's file name, and every commit of the run goes on one of them.
Every name comes from `specbranch`:

- `specbranch --list <spec path>` lists the run's existing branches
- `specbranch <spec path> <what the PR delivers>` prints the name of a new one

Refuse to start, touching nothing, when any of these holds:

- the spec does not exist where I stand
- the working tree holds anything but a spec as `/spec` leaves it
- a rebase is in progress
- the spec is committed and has uncommitted changes

A spec as `/spec` leaves it is either of these, and nothing else uncommitted:

- the new spec, with a tracked `alignment.md` removed
- the new spec alone, when `alignment.md` was never committed

When the run has branches it has started: resume them.
The run's base is the commit those branches grew from.

When it has none, create the first one from the commit I stand on, which becomes the run's base.
An uncommitted spec is the first commit on that branch, with the removal of `alignment.md` when there is one.

The branch I was on is left as it was.

## The spec

It does not track which steps are done.
A step is done when its checks pass on the branches; the pending work is whatever the spec asks for and the branches lack.
So a rerun needs nothing special: it builds what is still missing.

## Surprises

A surprise is a decision the spec did not make, or anything the spec got wrong.

Wherever in the loop one appears:

1. Invoke the `decide` skill through the Skill tool, with the question and what was found.
   - `Non-goals` bound what may be chosen.
2. Take its choice, whether the principles settled it or left it open.
3. Correct the body of the spec, which always describes the code as built.
4. Append an entry to `Changelog`.

Every edit to the body has an entry, which carries the reason the diff cannot.
`Changelog` is a flat list, appended to in the order things happened:

- an entry is what was found, with the reason for the choice nested under it
- the diff of the body already carries what the spec assumed and what was chosen
- an entry names no part of the spec, no principle, no date, and no commit hash or headline

## PRs

Cutting the work into commits and PRs is done while building.
Where to cut a PR is a choice for `decide`, as a surprise is, but it is no surprise and gets no entry.

Whatever the cut, this always holds:

- each PR passes the project's checks on its own
- each PR is based on the run's base or on another PR of the run, whichever its change needs
- PRs with a shared base and no need of each other are parallel branches
- the repo's own PR conventions win: a PR template, then `CONTRIBUTING.md` where it says how PRs are cut

Parallel branches that both add entries conflict at the end of the spec, and that is accepted.
I rebase the second one to merge, keeping both entries.

## The loop

One commit at a time:

1. Read the branches from git: each one's base, and what it holds over that base.
2. Choose the next commit, following `Plan` order: a branch and a change.
   - A new branch also chooses which existing one it starts from.
   - Read the spec as it is on the branch about to be committed to.
3. Implement it, editing the code directly and following the project's existing conventions.
   1. NOTE: do not read my coding principles yet.
4. Find the project's existing checks (tests, type checker, linter) from its config, run the relevant ones and get them passing.
5. Only now, invoke the `refactor` skill through the Skill tool, with no arguments, so it runs on the uncommitted diff.
   - It is the full pass every time, however small the commit.
   - Then run the checks again and get them passing.
6. Commit, under a short headline that fits the repo's convention.
   - The spec's edits and entries go in the commit of the code they describe.
   - The commit stands.
7. Repeat until every step's checks pass.

End by listing each branch of the run with its base.
