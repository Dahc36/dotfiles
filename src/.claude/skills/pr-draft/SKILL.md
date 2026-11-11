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

## The context

`alignment.md` at the root of the project, when it exists, ends with the decision of how the work ships.
The PR in it whose work the branch's commits match carries a sub-list of why the change exists, its decisions and its manual verification steps.
That sub-list is the first source for the why and the decisions, read before the diff.
Its lines are facts for the body, not text to paste: the body is still written in the PR's shape.

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
  - When the context says nothing about the why and the change leaves it unclear, write the best inference and start it with `(INFERRED)`.
- What changes were made, as the core decisions the rest of the changes follow from.
  - A decision is a choice the diff does not explain by itself; the diff already shows what changed in each file.
  - One line per decision, carrying the decision only (reasons should be explained in the "why" section).
  - Sub decisions or any color added to a decision should be a sub-iem of the main decision.
  - The same decision applied in several files is one line; specific files should not be named in general.
  - In whatever order explains them best, which is seldom diff order.
- When tests or any automation cover changes, just state that: "Covered by CI"
- How the change is verified.
  - If any manual check is needed, or a smoke test or a whole flow, it should be detailed as numbered steps.
  - A step names the place to go and the control to act on: the story, screen or command, then the button or field.
  - Those names are looked up in the repo, so the reader finds them as written: the story title, the screen route, the button label.
  - Manual steps are followed by placeholders for their evidence, in the same section, with no heading of their own.
    - CI alone gets no evidence, nor a mention of it.
    - Evidence is never captured, only drafted as embeds with `TODO` as their source.
      - Filling one is pasting the attachment URL in place of `TODO`.
    - One step, or several steps in the same place and flow, get a single embed.
    - Several steps that each open a different story, screen or command get a table.
      - One row per step.
      - The first column is the case, named by what the step opens.
      - Then one column per place the steps run in, named as the steps name it, like "Storybook", or "Web" and "Mobile".
    - The embed follows the step's expected result:
      - Motion or a sequence, like typing, pressing, an animation or a sheet opening: `<video src="TODO">`.
      - A static look, like a color, a layout or a value shown: `<img src="TODO">`.
      - Both: a video.

It is always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

## The go-ahead

Only after I say to open the PR:

1. Trim `alignment.md` when it holds the PR, without committing:
   1. Remove the PR's sub-list.
   2. Remove the shipping decision when no PR is left in it.
   3. Remove the file when nothing else remains.
2. Push the branch when `origin/<branch>` does not exist or is behind: `git push -u origin <branch>`.
   1. Never force push; if the push is rejected, say so and stop.
3. Read the title from the first line of `PR.md`.
4. Read the body from the rest, so that my edits are what gets posted.
   1. NOTE: evidence placeholders left in it do not block; they are filled on GitHub, where attachments are uploaded.
5. Open the PR with `gh pr create --draft --base <base> --title <title> --body-file <body>`.
   1. Nothing else is set: no reviewers, labels, assignees or project.
6. Remove `PR.md`.
7. End with the PR URL.

## Process

1. `git fetch origin`, then stop and say so, touching nothing, if any of these holds:
   - `$ARGUMENTS` is empty and `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
   - the base branch does not exist on origin
   - the current branch is the base branch
   - `git log origin/<base>..HEAD` prints nothing
   - `gh pr view` finds an open PR for the branch
   - a `PR.md` exists at the root of the project, tracked or not
2. Read the context, then the change and the other sources of its why.
3. Find the conventions.
4. Write `PR.md`, following only the conventions.
5. Read every file printed by `aiprinciples prose` and apply them to `PR.md`.
6. Distill the "why this change exists" and "what changes were made" sections to their very essence.
7. Offer to open the draft PR, and wait.
   1. I may have made changes directly to PR.md, open the draft with those included.
   2. Do not add an attribution line or co-creators.
8. With the PR open and `alignment.md` trimmed, offer to commit the trim with a short headline that fits the repo's convention.
   1. Accepting also pushes, never with force.
9. Offer to run /review on the open PR
