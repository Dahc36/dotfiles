# Plan: loop-review-improve

## Facts

- `loop-review`, built in full, posts a draft review on each PR requesting me and tracks it on `reviews/index.html`:
  - a round's artifacts are flat files in `reviews/`, named `<repo>-<number>-<round>.<kind>`
  - submitting ends the round: its files and transcripts are deleted and the PR leaves the page
  - a review submitted on a PR it never drafted is ignored
  - a step that fails puts the PR in `failed`, and the page offers that step's rerun
- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line> <RIGHT|LEFT>`, with `<start>-<end>` for a range
  - `## Unsettled`
- `Dahc36/dotfiles` is public.
- Dotfiles lives at `~/code/dotfiles`.
- Skills and principles are symlinks into the dotfiles working tree; `aiprinciples` reads `principles/` and is linked at `~/bin/aiprinciples`.
- `claude -p "/<skill> <args>"` runs a user skill, even with `disable-model-invocation: true`, and passes the args as `$ARGUMENTS`.
- `--output-format json` returns `result`, `is_error`, `subtype`, `permission_denials`, `session_id` and `total_cost_usd`.
- `--disallowedTools` still denies under `bypassPermissions`, and the denial shows in `permission_denials`.
- `--disallowedTools` rules match command prefixes:
  - `Bash(gh api -X:*)` let `-XPOST`, `--method POST`, `-f` and a trailing `-X POST` through.
  - `Bash(gh:*)` denied `gh` by absolute path, through `env`, and after `cd . &&`.
- `--max-budget-usd` checks a client-side estimate at list prices: it spends no money and protects no usage limit.
- Each session folder gets its own `~/.claude/projects/<path-with-dashes>/`, holding `<id>.jsonl` and a `memory/` folder.
- GitHub's GraphQL has what the runner needs:
  - `PullRequestReviewComment` has `line`, `startLine`, `body` and `lastEditedAt`.
  - `PullRequestReview` has `state`, `author`, `submittedAt`, `body` and `comments`.
- A deleted review comment disappears from `comments`, leaving no timestamp.
- `GET /repos/<owner>/<repo>/pulls/<n>/reviews` lists every review with its author and state.
  - Replying to a thread also creates a `COMMENTED` review.

## Decisions

1. Nothing here is built until all of `loop-review` is.
2. Submitting no longer ends the round: the PR goes to `comparing`.
   - A submitted review is checked before whether the PR is closed, so a round I submitted goes to `comparing` even after a close or merge.
3. The round gets one more file in `reviews/`: `<repo>-<number>-<round>.discrepancies.json`.
4. When I submit a review, the skills improve from it:
   1. The runner fetches my submitted review: body and comments.
   2. `/review-compare` writes the round's discrepancies file, one entry per difference: a deleted, rewritten or added comment, or the body I wrote.
   3. With no discrepancies, the round's files are deleted and the PR leaves the page.
   4. Otherwise I run `/review-improve <path>` from dotfiles, copying the command from the page.
5. `/review-compare` runs as a `claude -p` session like `/review` and `/review-draft`:
   - `--permission-mode auto`, and `--model` from `models` in `config.json`, defaulting to `opus`
   - `--disallowedTools` denying `git push`, `gh auth token` and `gh` entirely
   - a 10-minute timeout and a $2 spend cap, failing the PR when hit, naming the step and the limit
6. The page gets two states:

   | State                 | Meaning                                          |
   | --------------------- | ------------------------------------------------ |
   | `comparing`           | I submitted; `/review-compare` running           |
   | `discrepancies found` | discrepancies file waiting for `/review-improve` |

7. The page offers, per new state:

   | State                 | Links              | Commands                 |
   | --------------------- | ------------------ | ------------------------ |
   | `comparing`           | PR                 |                          |
   | `discrepancies found` | PR, discrepancies  | `/review-improve <path>` |

   - `re-compare`, the rerun `failed` offers after `/review-compare`, reruns it.
8. A submitted round's files and transcripts are deleted only from `discrepancies found`:
   - once `/review-improve` deletes its discrepancies file
   - at once, when `/review-compare` finds none
   - A submitted round goes through `comparing` and `discrepancies found` as usual, closed or not.
9. `/review-improve` is interactive, modeled on `/align-build`:
   1. It stops unless the dotfiles working tree is clean.
   2. We align on one commit's worth of improvement, dismissals included, one question at a time.
   3. It edits the skill files locally, following `aiprinciples prose`, and suggests a commit message; it never stages or commits.
   4. It removes that round's discrepancies from the file.
   5. It waits for me to commit, checks the tree is clean again, and goes on to the next round.
   6. It deletes the file once it is empty.
   - NOTE: the file holds only what is left, so a session can stop anywhere and resume later.
10. `/review-improve` keeps company content out of dotfiles:
    - skill edits and commit messages never carry repo names, PR numbers, identifiers or code from the reviewed repo
    - examples in a skill are made up, and each lesson is stated as a general rule
11. The two skills live in dotfiles, next to `/review` and `/review-draft`:
    - `/review-compare` finds the discrepancies between my submitted review, `review.md` and the draft.
    - `/review-improve` turns the discrepancies into skill edits, with me.
