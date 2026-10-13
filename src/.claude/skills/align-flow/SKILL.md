---
name: align-flow
description: Deliver the next step of alignment.md at once, built in the background since the previous call, and start building the step after.
disable-model-invocation: true
---

Keep me in the flow of building with `/align-build`: deliver the next step of `alignment.md` into my working tree at once, then start building the step after in the background, so that the next call is instant.

`/align-build` is invoked through the Skill tool, live in the session or ahead of time in a worktree.

## The speculation

A speculation is one `/align-build` run ahead of time, from a snapshot of my working tree, in a worktree of its own. There is at most one per session, and it lives entirely in the session scratchpad: the worktree at `<scratchpad>/align-flow/worktree/`, the summary of the run at `<scratchpad>/align-flow/summary.md`. Nothing survives the session; a new session starts cold.

Other sessions may be running their own flows at the same time, on this repository or another. Each one only ever touches the worktree in its own scratchpad: never remove, read or apply a worktree you did not create, and `git worktree prune` only clears bookkeeping for worktrees whose directory is gone. Two flows on the same repository that speculate from different states resolve themselves at delivery, through the `HEAD` comparison.

The snapshot is a commit of the working tree as it stands, made with plumbing so that my index, branch and `HEAD` stay untouched:

```
IDX=$(mktemp -u)
GIT_INDEX_FILE=$IDX git add -A
TREE=$(GIT_INDEX_FILE=$IDX git write-tree)
SNAP=$(git commit-tree "$TREE" -p HEAD -m "align-flow snapshot")
rm -f "$IDX"
git worktree add --detach <scratchpad>/align-flow/worktree "$SNAP"
```

The worktree's `HEAD` is the only reference to the snapshot commit; once the worktree is gone, git garbage-collects it.

The run is a general-purpose subagent in the background, told that:

- the worktree is the project root: every path, command and edit stays under it, never touching the real repository
- it invokes the `align-build` skill and follows it as written, except that it never asks a question: if a step needs a decision `alignment.md` does not settle, or checks cannot be made to pass, it stops, leaves the worktree as it is, and reports why
- it writes its final summary to `<scratchpad>/align-flow/summary.md`, with `READY` or `STOPPED: <reason>` as the first line and paths relative to the project root

When the notification that the subagent finished arrives, stay silent: do not act on it and do not report it. It is read at the next call.

Discarding a speculation means stopping the subagent if it is still running, removing the worktree with `git worktree remove --force`, and deleting `<scratchpad>/align-flow/`.

If I ask you to tweak the working tree in this session between calls, discard the speculation and, once the tweak is done, start a fresh one from a new snapshot. Tweaks made outside the session are caught by the `HEAD` comparison at the next call. There is no three-way rescue of a stale speculation.

Nothing is ever committed or staged on my branch. Committing is mine.

## Process

1. Run `git worktree prune`, then report the status of the speculation in one line, before anything else:
   - ready, so applying: `summary.md` starts with `READY`
   - stopped because it needed a decision or failed checks, so running `/align-build` live: `summary.md` starts with `STOPPED`
   - still running, so waiting for it: there is no `summary.md` and its subagent is still running. Wait until the file appears, then report again
   - none, so running `/align-build` live: there is no worktree
   NOTE: a worktree without `summary.md` whose subagent is not running, because it never launched or ended without writing the summary, is stopped.
2. Deliver the next step. Exactly one of these applies:
   - The working tree is not clean: say so and stop without touching anything. The speculation keeps waiting for the next call.
   - The speculation is ready and its snapshot tree matches `HEAD`: apply it. Stage everything in the worktree, apply the diff to my working tree, discard the speculation, and print `summary.md`.
     ```
     git -C <worktree> add -A
     git -C <worktree> diff --cached --binary | git apply
     ```
     NOTE: the snapshot is the worktree's `HEAD`; the trees match when `git rev-parse HEAD^{tree}` equals `git rev-parse <snapshot>^{tree}`.
     NOTE: `git apply` leaves the changes unstaged, code and `alignment.md` alike, exactly as a live `/align-build` would.
     NOTE: do not re-run the checks after applying. The speculation already ran them on the same tree, its summary reports the result, and `git apply` fails outright rather than partially; a second run verifies nothing new.
   - Anything else, so the speculation is stopped, was built on a state other than `HEAD`, or there is none: discard it if there is one, and run `/align-build` live in the session, as written, questions included.
3. Start the next speculation from the resulting state: take the snapshot, add the worktree, launch the subagent, and end with one line saying that the step after is being built in the background.
   NOTE: if `alignment.md` is gone, start nothing and report that the flow is complete.
