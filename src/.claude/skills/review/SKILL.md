---
name: review
description: Review a PR for bugs and then for code quality against my practices, writing each finding as a draft GitHub comment into review.md.
argument-hint: '<PR number, URL or branch>'
disable-model-invocation: true
---

Review the PR `$ARGUMENTS` and write every finding as a draft comment into `review.md`, ready for me to paste into GitHub.

Nothing is ever posted to GitHub, and never offer to. Posting is mine.

## Findings

Two kinds, found in two separate passes, in this order:

1. Bugs: unintended behavior, and contradicting behavior, where the code disagrees with the description or linked context, or two parts of the change disagree with each other. The bar is low: every suspected bug goes in.
   1. A confirmed bug, with the code path read end to end or an experiment run, is stated as a fact: the failing input and the wrong outcome. If something was run, say what.
   2. An unconfirmed one is phrased as a question to the author, with the scenario that worries you.
   3. Bugs are reported wherever the change causes them, on lines the PR touched or not.
   4. Never run the project's test suite or checks; CI does that. Running an experiment, or exercising behavior that has no coverage, is fine when it confirms a suspected bug.
   5. A bug that CI should have caught (a type error, a lint failure, a failing test) and did not is reported as a CI blind spot, not as the bug.
      1. Check the PR's checks with `gh pr checks <number>`.
      2. When they are green, find which step should have failed and why it did not.
      3. Write one finding with the concrete fix (the missing script, the excluded path, the skipped package), anchored to the touched line that exposed the failure, not to the CI config.
      4. Cite one failure as evidence and enumerate no others, even when several exist: fixing CI surfaces them all.
2. Quality: defined by every `.md` file in `~/.claude/skills/practices/` and by the repo's own established conventions. The bar is high: a finding exists only when you can show the concrete better version and say in one line why it is better for this code.
   1. Only on lines the PR touched.
   2. Practices are broad guidelines, applied with judgment. Never apply one mechanically.

## review.md

Written at the root of the project, never committed, and `.gitignore` is not touched. It opens with `# PR <number>: <title>`, then the findings. No verdict, no praise, no closing take. With no findings, it is still written, with a line saying so.

Findings are in the order GitHub's "Files changed" tab shows them: files as `git diff --name-only` lists them, then ascending line. They are numbered in that order, so that a finding can be referred to by its number.

Each finding is one block:

- a header line, `## <number>. <BUG|QUALITY> <path>:<line>`, with `<path>:<start>-<end>` for a range and the tier before the kind when there is one, `## <number>. BLOCK BUG <path>:<line>`
- the comment body, ready to paste into GitHub as a review comment on that location

The location is always a line the PR touched, even when the file has untouched lines GitHub would accept a comment on. When the finding lives on an untouched line, in a touched file or not, anchor it to the touched line that caused it (the deleted token, the renamed prop, the changed type) and name the real file and line in the body. A fix given for another location goes in a regular fenced block, never a ```suggestion block, since it would not apply at the anchor.

The body follows my `documenting` practice.
It is always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

Every claim that code can prove gets a GitHub permalink, `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<n>` or `#L<a>-L<b>`. The sha is the PR head for code on the branch and the merge base, `git merge-base origin/<base> HEAD`, for code the PR removed. The links go in a `Sources:` list at the end of the finding, one bullet per claim with a few words naming what the line shows, never inline in the prose. A finding whose claims are all on the anchored lines, or in the same file, has no list.

When the fix is a drop-in replacement of the anchored lines, give it in a ```suggestion block, so the author can apply it in one click. When it is not a drop-in, give the shape of it in a regular fenced block with the language. Code in either follows my coding practices.

## Tiers

A tier marks a finding I can act on without thinking twice: it is about confidence, not severity.

- `BLOCK`: high confidence that a change is needed. A confirmed bug that ships wrong behavior, or a CI blind spot that keeps hiding bugs of that kind.
- `NIT`: high confidence that no change is fine. Naming, wording, a nicer shape with no behavioral difference: the author's call, no reply expected.

An unconfirmed bug is a question the author settles, so it never has a tier. Tiers are decided over the finished `review.md`, so that each finding is weighed against the whole set.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - there is no argument
   - `gh pr view $ARGUMENTS` finds no PR, or the PR is not open
   - a `review.md` already exists at the root of the project
   - `git status --porcelain` prints anything; untracked files count as dirty
2. Check out the PR at its latest head: `gh pr checkout <number>`, then `git pull --ff-only`. If the fast-forward fails, say so and stop; never merge or reset.
   NOTE: stay on the PR branch when done.
3. Read the context the author shared: the title, the body, and whatever the body links to (issues, docs, other PRs). Do not read existing review comments or threads: duplicates are fine, and reading them biases the review toward what others already flagged.
4. Bug pass, with only `documenting.md` read from my practices. Fetch the PR's base branch and take the change as `git diff origin/<base>...HEAD`. Read every changed file in full, plus callers and callees when needed to judge a finding.
5. Quality pass. Read every other `.md` file in `~/.claude/skills/practices/`, then review the touched lines against them and the repo's conventions.
6. Write `review.md`.
7. Triage: read `review.md` top to bottom and add the tier to the headers that earn one. Nothing else in the file changes: no finding is dropped, merged, reworded or reordered.
8. End with one line: how many bugs and quality findings were written, how many are `BLOCK` and how many `NIT`, and that `review.md` is at the root.
