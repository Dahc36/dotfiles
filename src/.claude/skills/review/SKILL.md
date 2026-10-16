---
name: review
description: Review a PR for bugs and then for code quality against my practices, writing each finding into review.md for me to write the review from.
argument-hint: '<PR number, URL or branch>'
disable-model-invocation: true
---

Review the PR `$ARGUMENTS` and write every finding into `review.md`, for me to write the GitHub review from.

Nothing is ever posted to GitHub, and never offer to. Posting is mine.

## Findings

Two kinds, found in two separate passes, in this order:

1. Bugs: behavior that hurts or could hurt someone once shipped, and contradicting behavior, where the code disagrees with the description or linked context, or two parts of the change disagree with each other.
   1. Who gets hurt, as illustrations and not a list. The test is the potential to hurt, not whether the case is named here.
      - a user: wrong data on screen, a worse or surprising experience, something that worked and no longer does
      - the business: a wrong amount stored, sent or charged
      - the team: an error, a page, a broken job
      - nobody yet: a wrong branch nothing reaches, a flag that does nothing, a weakness nobody exploits
   2. A suspicion is sharpened until it has a mechanism (the input, the path and the wrong outcome) and a concrete way to check it. "Might be slow" becomes a query count and a fixture to run it against; "looks fragile" becomes the input that breaks it and where to send it.
   3. Then it is settled, wherever the answer is: the code path read end to end, with callers and data shapes; a dependency's installed source, docs, changelog and issue tracker; a throwaway experiment (a script, a REPL call, a one-off test written and deleted) when reading is not enough. Never run the project's test suite or checks; CI does that. Experiments leave the working tree as they found it.
   4. A settled bug is stated as a fact: the failing input, the wrong outcome, and the evidence in a form the author can rerun. The command or script and its output, in a fenced block, when something was run; permalinks when it was settled by reading. A claim is settled only if the finding shows how.
   5. A bug stays unsettled only when the answer sits with the author or behind something out of reach (production data, a gated system). The finding then says what was checked and gives the way to settle it: a query to run in production, a manual step, logs or a metric to watch, a pressure test, a sandbox call, or a question to a named person.
   6. Every bug finding states the consequence: who notices and how, or for a latent one, when it would start to.
   7. Bugs are reported wherever the change causes them, on lines the PR touched or not.
   8. A suspicion that could not be made checkable is not a finding. It goes in the `Unsettled` list at the end of `review.md`.
   9. A bug that CI should have caught (a type error, a lint failure, a failing test) and did not is reported as a CI blind spot, not as the bug.
      1. Check the PR's checks with `gh pr checks <number>`.
      2. When they are green, find which step should have failed and why it did not.
      3. Write one finding with the concrete fix (the missing script, the excluded path, the skipped package), anchored to the touched line that exposed the failure, not to the CI config.
      4. Cite one failure as evidence and enumerate no others, even when several exist: fixing CI surfaces them all.
2. Quality: the code as-is will be hard to understand, follow or maintain. This prevents bad code; it does not improve fine code. A finding exists only when the harm is shown as work someone will have to do (a reader jumping through files, holding several conditions in their head, knowing an unwritten convention; a maintainer touching several places, updating a parallel list) and the concrete better version is given.
   1. Only on lines the PR touched.
   2. The practices, every `.md` file in `~/.claude/skills/practices/`, and the repo's own established conventions name the why when one fits. They are never the limit: a harm with no practice behind it is a finding, a practice violation with no shown harm is not. Never apply one mechanically.

## review.md

Written at the root of the project, never committed, and `.gitignore` is not touched. It opens with `# PR <number>: <title>`, then the summary, then the findings, then the `Unsettled` list. No verdict, no praise, no closing take. With no findings, the summary is followed by a line saying so.

The summary has two parts, each an enumeration with sub-items for grouping and clarifying, optionally followed by whatever else helps understand it (code, a diagram, a table):

- `Intent`: the intended changes, as the author states them. When they say little, a line saying so.
- `Implementation`: what the diff does, in whatever order explains it best, which is seldom diff order.

The summary names no problem: those are findings, and the two never overlap.

Findings are in the order GitHub's "Files changed" tab shows them: files as `git diff --name-only` lists them, then ascending line. They are numbered in that order, so that a finding can be referred to by its number.

Each finding is one block:

- a header line, `## <number>. <BUG|QUALITY> <path>:<line>`, with `<path>:<start>-<end>` for a range
- the body, for me to understand the finding

Assume I have read the summary and nothing else of the PR, and that I have not memorized it. Reading the body must beat reading the PR: it explains enough to understand the problem, and nothing more. Three parts, in this order, each in whatever form explains best, prose, code, a list or a table:

1. What happens there, naming the part of `Implementation` it belongs to, as a reminder.
2. What is wrong, with the evidence, and the consequence for a bug or the harm for a quality finding.
3. The fix, when there is one, or the way to settle an unsettled bug.

The location is always a line the PR touched, even when the file has untouched lines GitHub would accept a comment on. When several touched lines are involved, the anchor is the line whose logic is wrong, not a line that sets up the situation. When the finding lives on an untouched line, in a touched file or not, anchor it to the touched line that caused it (the deleted token, the renamed prop, the changed type) and name the real file and line in the body. A fix given for another location goes in a regular fenced block, never a ```suggestion block, since it would not apply at the anchor.

The summary and the bodies follow my `documenting` practice.
They are always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

Every claim that code can prove gets a GitHub permalink, `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<n>` or `#L<a>-L<b>`. The sha is the PR head for code on the branch and the merge base, `git merge-base origin/<base> HEAD`, for code the PR removed. The links go in a `Sources:` list at the end of the finding, one bullet per claim with a few words naming what the line shows, never inline in the prose. A finding whose claims are all on the anchored lines, or in the same file, has no list.

Anything worth lifting into the review, wherever it appears (an example of the issue, how the change affects existing behavior, the evidence, the fix, a link), is written so that it can be pasted into GitHub as is.

When the fix is a drop-in replacement of the anchored lines, give it in a ```suggestion block, so that once pasted it applies in one click. When it is not a drop-in, give the shape of it in a regular fenced block with the language. Code in either follows my coding practices.

`Unsettled`, under a `## Unsettled` header after the last finding, is a list with one line per suspicion that could not be made checkable: the suspicion and why. It is omitted when there is none, and `review-check` ignores it.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - there is no argument
   - `gh pr view $ARGUMENTS` finds no PR, or the PR is not open
   - a `review.md` already exists at the root of the project
   - `git status --porcelain` prints anything; untracked files count as dirty
2. Check out the PR at its latest head: `gh pr checkout <number>`, then `git pull --ff-only`. If the fast-forward fails, say so and stop; never merge or reset.
   NOTE: stay on the PR branch when done.
3. Read `documenting.md` from my practices, then the context the author shared: the title, the body, and whatever the body links to (issues, docs, Slack threads, other PRs, a file or line the author points at). Nothing else of the PR's code is read yet. Do not read existing review comments or threads: duplicates are fine, and reading them biases the review toward what others already flagged.
4. Write `review.md` with the title and `Intent`, before reading any code, so that `Intent` cannot come from the code.
5. Read the change. Fetch the PR's base branch and take it as `git diff origin/<base>...HEAD`. Read every changed file in full, plus callers and callees when needed to understand it.
6. Write `Implementation`.
7. Bug pass.
8. Quality pass. Read every other `.md` file in `~/.claude/skills/practices/`, then review the touched lines against them and the repo's conventions.
9. Write the findings and the `Unsettled` list.
10. Check that `git status --porcelain` prints only `review.md`; remove whatever an experiment left behind.
11. End with one line: how many bugs and quality findings were written, how many of the bugs are unsettled, how many suspicions are in `Unsettled`, and that `review.md` is at the root.
