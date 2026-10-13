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
2. Quality: defined by every `.md` file in `~/.claude/skills/practices/` and by the repo's own established conventions. The bar is high: a finding exists only when you can show the concrete better version and say in one line why it is better for this code.
   1. Only on lines the PR touched.
   2. Practices are broad guidelines, applied with judgment. Never apply one mechanically.

## review.md

Written at the root of the project, never committed, and `.gitignore` is not touched. It holds the PR number and title, a bugs section and a quality section. No verdict, no praise, no closing take. With no findings, it is still written, with a line saying so.

Each finding is one block:

- a header line with the kind and the location, as `path:line` or `path:start-end`
- the comment body, ready to paste into GitHub as a review comment on that location

The body follows my `documenting` practice.
It is always in English. Identifiers and business terms that already exist in another language stay as they are, never translated.

When the fix is a drop-in replacement of the anchored lines, give it in a ```suggestion block, so the author can apply it in one click. When it is not a drop-in, give the shape of it in a regular fenced block with the language. Code in either follows my coding practices.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - there is no argument
   - `gh pr view $ARGUMENTS` finds no PR, or the PR is not open
   - a `review.md` already exists at the root of the project
   - `git status --porcelain` prints anything; untracked files count as dirty
2. Check out the PR at its latest head: `gh pr checkout <number>`, then `git pull --ff-only`. If the fast-forward fails, say so and stop; never merge or reset.
   NOTE: stay on the PR branch when done.
3. Read the context the author shared: the title, the body, and whatever the body links to (issues, docs, other PRs). Do not read existing review comments or threads: duplicates are fine, and reading them biases the review toward what others already flagged.
4. Bug pass, with only `documenting.md` read from my practices. Fetch the PR's base branch and take the change as `git diff origin/<base>...HEAD`. Read every changed file in full, plus callers and callees when needed to judge a finding. Write the bugs section.
5. Quality pass. Read every other `.md` file in `~/.claude/skills/practices/`, then review the touched lines against them and the repo's conventions. Write the quality section.
6. End with one line: how many bugs and quality findings were written, and that `review.md` is at the root.
