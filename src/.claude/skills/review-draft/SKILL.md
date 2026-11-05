---
name: review-draft
description: Follow-up to /review. Turn a review.md into a draft of my pending review, one comment per finding, rewritten in Spanish in my voice.
argument-hint: '<review.md path> <head sha>'
disable-model-invocation: true
---

Turn the `review.md` at the given path into a draft of my pending review, so that it reads as if I had written it.

`$ARGUMENTS` is two arguments, in this order: the path of `review.md`, and the head sha the review was made on.

Nothing is ever written to GitHub, and `gh` is never called.
The comments come from `review.md` alone: the findings carry the evidence, and the reviewed repo is never read.

## The draft file

Written next to `review.md`: its path with the `review.md` ending replaced by `draft.json`.
`x-12-1.review.md` gives `x-12-1.draft.json`; a bare `review.md` gives `draft.json`.

It is JSON with exactly these fields:

- `head`: the head sha, as given; never looked up.
- `comments`: one per finding, in the findings' order, each with exactly:
  - `path`, `line` and `side`, from the finding's header `<path>:<line> <SIDE>`
  - `startLine`, only when the header is a range `<path>:<start>-<end> <SIDE>`: `startLine` is `<start>` and `line` is `<end>`
  - `body`: the comment
- `body`: only when there are no findings, with `comments` as `[]`
  - it is `LGTM`, then one emoji that fits the change as the summary describes it, or none when none fits
  - with findings there is no `body` field

Every finding gets exactly one comment: none is dropped, none is merged.
What goes into the review is mine to decide, by deleting comments in GitHub's "Files changed" tab.

The summary and the `Unsettled` list are not in the draft.

## A comment

Its wording is rewritten from its finding, never copied, in three parts, in this order, and nothing else:

1. What is wrong, short, with its consequence on its own line.
2. The evidence as the finding gives it: the rerunnable command and its output, or the permalinks.
3. The fix, in the finding's ```suggestion block when it has one, or the way to settle an unsettled bug.
   - Context the fix depends on goes here too, such as a linked PR or a design left unchecked.

No reminder of what the code does, no `BUG` or `QUALITY` label, no finding number.

Code, commands, their output and links are copied from the finding byte for byte, never retyped or translated.

The rules a comment cannot break, since one broken rule gets the whole draft refused when posted:

- It is anchored where its finding is, so on touched lines: added and context lines on `RIGHT`, removed lines on `LEFT`, every line of a range included.
- A ```suggestion block goes only on `RIGHT`, on a range GitHub can apply, and at most one per comment.
  - A fix for a `LEFT` anchor, a deleted line, goes in a regular fenced block with the language, even when the finding gives it as a suggestion.
- Every permalink into the reviewed repo resolves: copied byte for byte, it keeps the sha, path and line numbers `/review` checked.

### Voice

- Written in Chilean Spanish. Code, identifiers and business terms stay as they are, never translated.
- Facts are stated impersonally: what happens, when, and what it causes. "esto falla cuando…", "el monto queda…"
- Recommendations and guidance are proposals, in first person plural or addressed to the author. "podríamos…", "deberíamos…", "¿te parece…?", "¿te tinca…?"
- It follows my prose principles.

## The judge

Each comment is checked against its finding by a fresh subagent, one that did not write it.
Spawn it through the Agent tool with a prompt that gives:

- the finding, header included, exactly as in `review.md`
- the comment: its `path`, `line`, `side`, `startLine` when present, and `body`
- the rules in "A comment" above, copied in full
- the task:
  - under `Blocking:`, report what the comment adds, drops or changes from the finding in the location, the claim, the consequence, the evidence and the fix
  - under `Blocking:`, report every rule the comment cannot break that it breaks
  - under `Blocking:`, report code, commands, their output and links that differ from the finding byte for byte
  - under `Notes:`, report every other rule in "A comment" the comment breaks: the parts, their order, length and voice
  - leave unreported the Spanish wording, and the reminder of what the code does, the label and the number, all dropped by design
  - return `PASS` alone when there is nothing to report

A comment passes when its report has nothing under `Blocking:`.

- A comment that passes with notes is rewritten once to apply them, and judged again by a new subagent.
  - If that rewrite has anything under `Blocking:`, the version that passed is kept.
  - Its new notes are left as they are.
- A failed comment is rewritten from its finding and the whole report, and judged again by a new subagent.
- After the third failure on one comment, stop: write no draft, and name the finding and the last report.
  - Only failures count; a notes rewrite never does.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - there are not exactly two arguments
   - the `review.md` path does not exist, or does not end in `review.md`, or its first line is not `# PR <number>: <title>`
   - the head is not a 40-character hex sha
   - the draft file already exists; deleting an old draft is the caller's job
2. Read every file printed by `aiprinciples prose`, then `review.md` in full.
3. Write each finding's comment.
4. Judge each comment, rewriting until it passes or stopping as "The judge" says.
5. Write the draft file, and check it with `jq empty <draft>`.
6. End with one line: how many comments, and where the draft is.
