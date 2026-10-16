---
name: review-check
description: Follow-up to /review. Compare my pending GitHub review on the PR in review.md with its findings, and report what I got wrong and what I left out.
disable-model-invocation: true
---

Read my pending review on the PR that `review.md` describes and compare it with the findings there. Report what I got wrong and what I left out, so that whatever is left out is left out on purpose.

Takes no arguments: everything comes from `review.md` and from the checkout `/review` left on the PR branch.

Nothing is ever posted, edited or deleted on GitHub, and never offer to.

## Inputs

- `review.md` at the root of the project, as written by `/review`. Its first line is `# PR <number>: <title>`. Its `Unsettled` list, when present, is not findings and is ignored.
- My pending review: the one review with state `PENDING` by the logged-in user in `gh api repos/<owner>/<repo>/pulls/<number>/reviews`, and its comments from `gh api repos/<owner>/<repo>/pulls/<number>/reviews/<id>/comments --paginate`. No other review, comment or thread is read.

The API gives no line number for a pending comment, so each one is matched to a finding by its `path` and what it says.

## Report

Printed, not written to a file. Three sections, each a list with one line per item, empty sections included with a line saying so:

1. Wrong: draft comments that would send the author to the wrong place or the wrong fix. Each item quotes the first line of the comment, then says what is wrong and what the code shows. The bar is high, only these count:
   - a wrong file, line, value, cause or fix
   - a `suggestion` block that is not a drop-in for its lines
   - a link whose file or line does not exist in the checkout
   NOTE: a hedged estimate, a typo in a name the author can still find, or a claim that is imprecise but leads to the same fix is not wrong. Wording, tone, length and language are never reported.
2. Left out: findings in `review.md` with no matching comment. Each item is the finding's number and its claim in a few words, nothing more; the list is for confirming intent, not for arguing the finding again.
3. Not in review.md: comments with no matching finding. Each item is verified against the code the same way as section 1 and says whether it holds.

A comment that merges several findings matches all of them. A comment that covers a finding partially counts as a match, and the part dropped is not reported.

End with one line: how many wrong, left out and new.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - there is no `review.md` at the root of the project, or its first line is not `# PR <number>: <title>`
   - `gh pr view <number>` finds no PR, or the PR is not open
   - `git rev-parse HEAD` differs from the PR's `headRefOid`; `review.md` refers to that commit, so delete it and run `/review` again first
   - there is no pending review by me on the PR
2. Read `review.md` in full and fetch the pending comments.
3. Match comments to findings, then verify every factual claim in a comment against the code at `HEAD`, reading the lines it names. A claim already verified by `/review` and repeated unchanged in the comment needs no second reading.
4. Print the report.
5. Offer to delete `review.md`, and delete it only if I say yes.
