---
name: review-bulk
description: Run /review on every open PR of this repo that requests my review directly, each in a fresh subagent, and commit each review.md locally on its PR branch.
disable-model-invocation: true
model: opus
---

Review the PRs waiting on me in this repo, one at a time, each by a fresh subagent following `/review`, and commit each `review.md` locally on its PR branch, so that `/review-check` can read it and the next run skips it.

Takes no arguments. Nothing is ever pushed or posted to GitHub, and never offer to.

## Queue

`~/.claude/skills/review-bulk/queue.bash` prints it, one branch per line: the open, non-draft PRs of the current repo that request my review directly, oldest PR first.

## The review.md commit

Each reviewed PR gets one local commit on its branch, on top of the PR head, never pushed. A commit is a `review.md` commit only when both hold:

- its message is `review.md`
- `git diff --name-only <commit>~1 <commit>` prints only `review.md`

## Plan per branch

After `git fetch origin`, the first row that matches the branch decides its plan:

| Branch                                                         | Plan     |
| -------------------------------------------------------------- | -------- |
| no `origin/<branch>`, the PR branch is gone                    | `failed` |
| no local branch                                                | `review` |
| at or behind `origin/<branch>`, no `review.md` commit on top   | `review` |
| a `review.md` commit on top of `origin/<branch>`, reviewed     | `skip`   |
| a `review.md` commit on top of anything else, the PR moved     | `review` |
| any other local-only commit                                    | `failed` |

- `review` checks the branch out at `origin/<branch>`, as "Reviewing one branch" says.
- `failed` is reported with the reason, and the branch is left untouched.
  NOTE: `review-bulk` never destroys what it did not create.

## Reviewing one branch

1. Check out the branch at `origin/<branch>`: `git checkout -B <branch> --track origin/<branch>`.
   NOTE: `-B` resets the branch; on a `review` plan, the only commit it can drop is a `review.md` commit.
2. Spawn a fresh subagent through the Agent tool. Its prompt gives:
   - the branch
   - to read `~/.claude/skills/review/SKILL.md` and follow it as written, with the branch as `$ARGUMENTS`
   - to commit nothing, and to return only its closing line, or the line saying why it stopped
3. Success is both:
   - it returned `/review`'s closing line
   - `git status --porcelain` prints exactly `?? review.md`
4. On success, `git add review.md && git commit -m review.md`.
5. On anything else, `git checkout -- . && git clean -fd`, report the branch as `failed` with the subagent's last line, and continue. The next run retries it, since no `review.md` commit exists.

## Report

One line per branch in queue order, `<branch>: reviewed|skipped|failed`, followed by `/review`'s closing line for the reviewed ones and the reason for the failed ones. Then one closing line with the counts.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - `git status --porcelain` prints anything; untracked files count as dirty
   - `git check-ignore -q review.md` succeeds; `review.md` could never show up as untracked
   - `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
2. Run the queue script, `git fetch origin`, and decide each branch's plan.
3. Print the queue, one line per branch with its plan, before the first subagent runs.
4. Review each branch whose plan is `review`, one at a time, in queue order.
5. Check out the default branch, the one `origin/HEAD` points at.
6. Print the report.
