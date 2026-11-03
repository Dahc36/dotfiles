# /review-draft replaces /review-check

## Facts

- `/review-bulk` posts each PR's draft from `/review-draft` as my pending review, and commits nothing.
- `/review-check` compares my pending review with `review.md`, read untracked or from a `review.md` commit on the PR branch.
- `/review` names `review-check` once, in its `Unsettled` paragraph.
- `make remove src/<path>` deletes a tracked file, prunes its empty parents under `src/` and unlinks its `~` symlink; the empty `~/.claude/skills/<name>` folder stays.

## Decisions

1. `/review-check` is deleted, and `/review`'s mention of it names `/review-draft` instead.
