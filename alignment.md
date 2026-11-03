# /review-draft

## Facts

- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line> <RIGHT|LEFT>`, with `<start>-<end>` for a range
  - `## Unsettled`
- A finding's body has three parts: what happens there, what is wrong with the evidence and the consequence, and the fix or the way to settle it.
  - A fix that drops in at the anchored lines on `RIGHT` is a ```suggestion block; any other fix is a regular fenced block.
  - Claims proven elsewhere are permalinks in a `Sources:` list at the end, one bullet per claim.
  - It is always in English; identifiers and business terms in another language stay as they are.
- `/review` anchors a finding on the touched line that caused it, a deleted line included.
- A deleted line exists only on the `LEFT` side of the diff.
- `loop-review post <clone> <number> <draft.json>` posts the draft as my pending review, pinned to its `head`:
  - On success it prints one JSON object: the review's id, the PR's URL and each comment's id in draft order.
  - It refuses, with a non-zero exit, on a pending review of mine, on a PR head other than the draft's `head`, and on any invalid comment, naming each and the rule.
- `loop-review post` reads the draft strictly: an unknown field, an empty `head` or a `startLine` after `line` is a refusal.
  - It does not take `body` yet; that is the runner's work, not this skill's.
- `claude -p "/<skill> <args>"` runs a user skill, even with `disable-model-invocation: true`, and passes the args as `$ARGUMENTS`.
- Every skill in dotfiles that I invoke by hand has `disable-model-invocation: true` and an `argument-hint` when it takes arguments.

## Decisions

1. `/review-draft` turns `review.md` into the draft file `loop-review post` takes.
   - It carries my instructions on tone, language and how each problem is presented.
   - Comments are rewritten, not copied from the findings.
2. The draft file is JSON with a top-level `head`, the sha reviewed, and `comments`, one per comment.
   - Each comment has `path`, `line`, `side` and `body`, plus `startLine` for a range, which is on one side.
   - The draft has a `body` only when there are no findings: `LGTM` and one emoji, picked at random by the skill.
     - With findings there is no `body` field, and the pending review's body stays empty.
3. Every comment follows `loop-review post`'s rules, so that nothing it writes is refused:
   - anchored on touched lines: added and context lines on `RIGHT`, removed lines on `LEFT`, every line of a range included
   - a `suggestion` block only on `RIGHT`, on a range GitHub can apply, and at most one per comment
   - every permalink into the reviewed repo resolves: the sha, the path at it and the line numbers
4. A fix for a deleted line goes in a regular fenced block, never a `suggestion` block.
5. The draft has exactly one comment per finding: no dropping, no merging.
   - What goes into the review is decided by me, by deleting comments in "Files changed".
6. The summary and `Unsettled` are not in the draft.
7. `/review-draft` checks each rewritten comment against its finding, with a judge that has not seen the rewrite.
   - A fresh subagent gets the finding, the comment and the rules, and reports what the comment adds, drops or changes: the location, the claim, the consequence, the evidence, the fix.
   - Code, commands, their output and links are copied byte for byte, so the judge compares those exactly.
   - A failed comment is rewritten and judged again.
   - After three failures on one comment the skill stops, writes no draft, and names the comment.
8. `/review-draft` writes nothing to GitHub and never calls `gh`; posting is `loop-review post`'s.
   - It works from `review.md` alone and never reads the reviewed repo: the findings carry the evidence.
9. `/review-draft` runs as its own `claude -p` session, apart from `/review`'s.
   - It runs on the moved `review.md` and writes the draft file next to it.
   - It can rerun alone, without a new review.
10. `/review-draft` lives in dotfiles, next to `/review`.
11. `/review-draft` has no `model` frontmatter, so that the runner's `--model` decides.
12. `/review-draft` takes two arguments: the path of `review.md` and the head sha reviewed.
    - The head goes into the draft as given; the skill never looks it up.
13. The draft file is the `review.md` path with its `review.md` ending replaced by `draft.json`.
    - `x-12-1.review.md` gives `x-12-1.draft.json`; a bare `review.md` gives `draft.json`.
    - A path that does not end in `review.md` stops the skill.
14. `/review-draft` stops and says so, touching nothing, when any of these holds:
    - the arguments are not exactly two
    - the `review.md` path does not exist, or its first line is not `# PR <number>: <title>`
    - the head is not a 40-character hex sha
    - the draft file already exists; deleting an old draft is the caller's job
15. Comments are written in Spanish.
    - Code, identifiers and business terms stay as they are, never translated.
16. Facts are stated impersonally: what happens, when, and what it causes.
    - "esto falla cuando…", "el monto queda…"
17. Recommendations and guidance are proposals, in first person plural or addressed to the author.
    - "podríamos…", "deberíamos…", "¿te parece…?", "¿te tinca…?"
18. Each comment has three parts, in this order, and nothing else:
    1. What is wrong and its consequence, in a line or two.
    2. The evidence as the finding gives it: the rerunnable command and its output, or the permalinks.
    3. The fix, in the finding's `suggestion` block when it has one, or the way to settle an unsettled bug.
    - No reminder of what the code does, no `BUG` or `QUALITY` label, no finding number.
19. The comments follow my prose principles: the skill reads every file `aiprinciples prose` prints before writing.
20. A finding's anchor becomes the comment's: `<path>:<line> <SIDE>` gives `path`, `line` and `side`; `<path>:<start>-<end> <SIDE>` adds `startLine`.
    - Comments are in the findings' order.
21. After writing the draft, the skill checks it parses with `jq empty`, and ends with one line: how many comments, and where the draft is.
