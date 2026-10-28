---
name: pr-draft
description: Draft the PR for the current branch into PR.md, following the repo's PR conventions, and open it as a draft PR only once I say so.
argument-hint: '[base branch, default the repository default branch]'
disable-model-invocation: true
---

Draft the PR for the current branch into `PR.md`, then offer to open it as a draft PR. Nothing is pushed or posted until I say so.

## The change

The base branch is `$ARGUMENTS`; when empty, the default branch, the one `origin/HEAD` points at.
The change is the commits of the current branch over `origin/<base>`:

- the commits: `git log origin/<base>..HEAD`
- the diff: `git diff origin/<base>...HEAD`

Uncommitted changes are ignored.
Read every changed file in full, plus callers and callees when needed to understand the change.

## The conventions

The draft follows the repo's own conventions, found in this order; the first that exists wins:

1. Any PR template you can find.
2. `CONTRIBUTING.md`, where it says how PRs are titled or written.
3. None of those: the shape that best explains this change.

## PR.md

Written at the root of the project, never committed, and `.gitignore` is not touched.
The first line is `# <title>`, the rest is the body exactly as it will be posted.

The title names the change in one line, in the shortest way possible. The less text the better.

Whatever sections the convention gives, they should carry:

- Why this change exists.
  - With the minimum context to understand the change itself, nothing more.
  - When the why is unclear, write the best inference and start it with `(INFERRED)`.
- What changes were made, as the core decisions the rest of the changes follow from.
  - A decision is a choice the diff does not explain by itself; the diff already shows what changed in each file.
  - One flat line per decision, carrying the decision and the reason for it.
  - The same decision applied in several files is one line; a file is named only when the decision concerns it alone.
  - In whatever order explains them best, which is seldom diff order.
- When tests cover changes, a mention of that fact is enough, no need to enumerate each automated test.
- How the change is verified.
  - If any manual check is needed, or a smoke test or a whole flow, it should be detailed as numbered steps.
  - A step names the place to go and the control to act on: the story, screen or command, then the button or field.
  - Those names are looked up in the repo, so the reader finds them as written: the story title, the screen route, the button label.

It is always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

## The go-ahead

Only after I say to open the PR:

1. Push the branch when `origin/<branch>` does not exist or is behind: `git push -u origin <branch>`.
   1. Never force push; if the push is rejected, say so and stop.
2. Read the title from the first line of `PR.md`.
3. Read the body from the rest, so that my edits are what gets posted.
4. Open the PR with `gh pr create --draft --base <base> --title <title> --body-file <body>`.
   1. Nothing else is set: no reviewers, labels, assignees or project.
5. Remove `PR.md`.
6. End with the PR URL.

## Process

1. `git fetch origin`, then stop and say so, touching nothing, if any of these holds:
   - `$ARGUMENTS` is empty and `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
   - the base branch does not exist on origin
   - the current branch is the base branch
   - `git log origin/<base>..HEAD` prints nothing
   - `gh pr view` finds an open PR for the branch
   - a `PR.md` exists at the root of the project, tracked or not
2. Read the change and the sources of its why.
3. Find the conventions.
4. Write `PR.md`, following only the conventions.
5. Read `documenting.md` from my principles (`~/.claude/skills/principles/documenting.md`) and apply it to `PR.md`.
6. End by offering to open the draft PR, and wait.
   1. I may have made changes directly to PR.md, open the draft with those included.
