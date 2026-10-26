---
name: pr-draft
description: Draft the PR for the current branch into PR.md, following the repo's PR conventions, and open it as a draft PR only once I say so.
argument-hint: '[base branch, default the repository default branch]'
disable-model-invocation: true
---

Draft the PR for the current branch into `PR.md`, then offer to open it as a draft PR. Nothing is pushed or posted until I say so.

## The change

The base is `$ARGUMENTS`, or the default branch, the one `origin/HEAD` points at, when empty. The change is the commits of the current branch over `origin/<base>`:

- the commits: `git log origin/<base>..HEAD`
- the diff: `git diff origin/<base>...HEAD`

Uncommitted changes are ignored.

Read every changed file in full, plus callers and callees when needed to understand the change.

## The conventions

The draft follows the repo's own conventions, found in this order; the first that exists wins:

1. A PR template, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, any file in `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md`: the body's sections, in its order, every one filled.
2. `CONTRIBUTING.md`, where it says how PRs are titled or written.
3. The last merged PRs, `gh pr list --state merged -L 15 --json title,body`: the title shape, and the sections their bodies share.
4. None of those: the shape that best explains this change, said so in the closing line.

## PR.md

Written at the root of the project, never committed, and `.gitignore` is not touched. The first line is `# <title>`; the rest is the body exactly as it will be posted.

The title names the change in one line, in the shape the convention gives it.

Whatever sections the convention gives, they carry:

- Why the PR exists, only from what the commits, the branch name and what they link to say, all read in full. The diff shows what, not why. When the why stays unclear, write the best inference and end it with `(inferred)`.
- What the diff does, in whatever order explains it best, which is seldom diff order.
- How a reviewer verifies it. When the diff adds or changes tests that cover the change, name them and say CI runs them. Otherwise write what a reviewer should do, ending with `(inferred)`.

The body names no problem with the change and gives no opinion on it: it describes, so that a reviewer reads the change knowing what to expect.

It is always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

## The go-ahead

Only after I say to open it:

1. Push the branch when `origin/<branch>` does not exist or is behind: `git push -u origin <branch>`. Never force push; if the push is rejected, say so and stop.
2. Read the title from the first line of `PR.md` and the body from the rest, so that my edits are what gets posted, then open the PR with `gh pr create --draft --base <base> --title <title> --body-file <body>`. Nothing else is set: no reviewers, labels, assignees or project.
3. Remove `PR.md`.
4. End with the PR URL.

## Process

1. `git fetch origin`, then stop and say so, touching nothing, if any of these holds:
   - `$ARGUMENTS` is empty and `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
   - the base branch does not exist on origin
   - the current branch is the base branch
   - `git log origin/<base>..HEAD` prints nothing
   - `gh pr view` finds an open PR for the branch
   - a `PR.md` exists at the root of the project, tracked or not
2. Read the commits, the diff and what they link to.
3. Find the conventions.
4. Write `PR.md`, following only the conventions.
5. Read `documenting.md` from my practices (`~/.claude/skills/practices/documenting.md`) and apply it to `PR.md`.
6. End with one line: whether no convention was found, how many sections end with `(inferred)`, and that `PR.md` is at the root. Then offer to open the draft PR, and wait.
