---
name: spec-propagate
description: Carry a corrected decision forward through the commits and branches built after it, keeping or dropping each one.
disable-model-invocation: true
---

Settle what survives a corrected decision: each commit built after it is kept or dropped.

I run it right after `/decide-fix`, in the interactive rebase I stopped with `edit` at the decision's commit.
Whatever is dropped, `/spec-build` builds again.

- Nothing changes before my go-ahead.
- The rebase stays stopped: continuing it is mine.
- Nothing is pushed.

Refuse to start, touching nothing, when no rebase is in progress.

## The correction

The old commit is the one the rebase stopped at, `REBASE_HEAD`.
The correction is how the working tree differs from it, which `git diff REBASE_HEAD` prints whether I amended the commit or not.

With no difference there is nothing to carry forward: say so and stop.

## The verdicts

Judge every commit built after the old one:

- each commit left in the rebase's todo
- each commit of any other branch that contains the old commit

Each commit gets a verdict, judged from its diff and never from its headline alone:

- keep: it neither touches what the correction changed nor relies on the old decision
- drop: it was built on the old decision
  - a commit that needs a dropped one is dropped too

Show the verdicts as one line per commit, in order and grouped by branch: the commit, its verdict and the reason.

The old commit's message is judged too:

- it still describes the corrected commit: it stays
- it states the old decision: propose the new message, shown with the verdicts

Then wait for me.
Change what I disagree with and show it again, until I give the go-ahead.

## Applying them

Amend the old commit with whatever of the correction is still uncommitted, under the message I agreed to.
My go-ahead is what accepts the correction.

Then rewrite the rest of the rebase's todo so that, once I continue, every kept commit sits on the corrected one and every branch points at its rewritten commits:

- a kept commit is a `pick`, and a dropped one a `drop`
- a branch that ends inside the rebased one gets an `update-ref` where its last commit was
- a branch that forks off the rebased one:
  - a `label` where it forks
  - after the rebased branch's own commits, a `reset` to that label, the branch's commits and its `update-ref`
- a last `reset` returns to the tip of the rebased branch, when any branch forked off

A branch whose commits were all dropped still gets its `update-ref`, at the commit it forked from.

Write the todo through `git rebase --edit-todo`, with `GIT_SEQUENCE_EDITOR` set to a command that puts the new todo in place.

- Git only honours the `update-ref` lines of a todo it has read through `--edit-todo`.
- Written straight to the file, they are skipped without a word.

## The end

Say where things stand, either of:

- nothing was dropped, and no build is needed
- what was dropped, branch by branch, and that `/spec-build` is next once the rebase is finished
