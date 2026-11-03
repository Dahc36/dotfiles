# /review-bulk posts my pending reviews

## Facts

- `/review-bulk` today reviews each PR branch in a fresh subagent and commits `review.md` on the branch, and that commit marks the PR as reviewed.
  - `/review-check` reads `review.md` from that commit and compares it with my pending review.
  - `/review` names `review-check` once, in its `Unsettled` paragraph.
- `/review-draft <review.md path> <head sha>` writes `<name>.draft.json` next to `review.md`, judging each comment in a subagent.
  - It refuses when the draft file exists, so a rerun deletes the old draft first.
- `loop-review post <clone> <number> <draft.json>` posts the draft as my pending review, pinned to its `head`:
  - On success it prints one JSON object: the review's id, the PR's URL and each comment's id in draft order.
  - It refuses, with a non-zero exit, on a pending review of mine, on a PR head other than the draft's `head`, and on any invalid comment, naming each and the rule.
- `loop-review` builds to `~/code/loop-review/loop-review` and is not on PATH.
  - `~/code/loop-review/reviews/` does not exist, and the clone's `.gitignore` ignores only the binary.
- GitHub allows one pending review per user per PR; a second one fails with a 422.
- `GET /repos/<owner>/<repo>/pulls/<n>/reviews` lists every review with its author and state, my `PENDING` one included.
  - Replying to a thread also creates a `COMMENTED` review.
- `gh pr list --json number,headRefName,headRefOid,reviewRequests` gives the queue the number and head sha along with the branch.
- `claude -p "/<skill> <args>"` runs a user skill, even with `disable-model-invocation: true`, and passes the args as `$ARGUMENTS`.
  - It runs inside a Claude Code session's Bash tool too, where `CLAUDECODE=1` is set.
  - The Bash tool waits at most 10 minutes in the foreground; a command run in the background notifies the session when it exits.
- `claude -p --permission-mode auto` runs unattended: a Bash command the prompt asks for runs, `git push` included, with nothing in `permission_denials`.
- `--output-format json` returns `result`, `is_error`, `subtype`, `permission_denials`, `session_id` and `total_cost_usd`.
- `--disallowedTools` still denies under `bypassPermissions`, and the denial shows in `permission_denials`.
- `make remove src/<path>` deletes a tracked file, prunes its empty parents under `src/` and unlinks its `~` symlink; the empty `~/.claude/skills/<name>` folder stays.

## Decisions

1. `/review-bulk`, per PR, checks out the branch in my clone, runs `/review`, moves `review.md` to `~/code/loop-review/reviews/`, runs `/review-draft` and `loop-review post`.
   - It skips a PR on which I already have a pending review, and commits nothing.
2. Every GitHub write is plain code, never a skill's: `/review-bulk` posts only through `loop-review post`.
3. The queue is the open, non-draft PRs of the current repo requesting me directly, oldest first.
4. `/review-check` is deleted, and `/review`'s mention of it names `/review-draft` instead.
5. `/review-bulk` runs `/review` and `/review-draft` as two `claude -p` sessions, each as a background Bash command, waiting for it to exit.
   - `--permission-mode auto`, plus `--disallowedTools` for GitHub writes:
     - every session denies `git push` and `gh auth token`
     - `/review` denies `gh api` entirely, plus the writing subcommands:
       - `gh pr review`, `comment`, `merge`, `edit`, `close` and `create`
       - `gh issue comment`, `create`, `edit` and `close`
     - `/review-draft` denies `gh` entirely
   - Deny rules match command prefixes, so this guards against accidents only.
   - `--output-format json`, read for `is_error`, `subtype`, `permission_denials` and `result`.
   - `--model opus` for `/review-draft`; `/review` keeps its `model: opus` frontmatter.
6. Each PR's files are flat in `~/code/loop-review/reviews/`:
   - `<repo>-<number>-<round>.review.md`
   - `<repo>-<number>-<round>.draft.json`
   - `<repo>` is the name from `origin`, and the round is 1 plus my reviews on the PR not in `PENDING` state.
   - A rerun within a round removes that round's old files before `review.md` is moved in.
7. `~/code/loop-review/reviews/` is created and ignored by hand, in the `loop-review` clone, before the first run.
   - `/review-bulk` stops, touching nothing, when the folder is missing.
8. After `git fetch origin`, the first row that matches the PR decides its plan:

   | PR                                                   | Plan     |
   | ---------------------------------------------------- | -------- |
   | my pending review on it, in the reviews list         | `skip`   |
   | no `origin/<branch>`, the PR branch is gone          | `failed` |
   | a local branch with a commit not on `origin/<branch>`| `failed` |
   | anything else                                        | `review` |

   - `skip` is decided before any git command touches the branch.
   - `failed` is reported with the reason, and the branch is left untouched: `/review-bulk` never destroys what it did not create.
   - A `review.md` commit from the old scheme is a local-only commit like any other.
9. Reviewing one PR, in order:
   1. `git checkout -B <branch> --track origin/<branch>`.
   2. The `/review` session, with the PR number as its argument.
      - Success is both: the session's `subtype` is `success` with `is_error` false, and `git status --porcelain` prints exactly `?? review.md`.
      - On anything else, `git checkout -- . && git clean -fd`.
   3. Move `review.md` to its round's path, removing the round's old files first.
   4. The `/review-draft` session, with the round's `review.md` path and the PR's head sha.
      - Success is both: the session's `subtype` is `success` with `is_error` false, and the draft file exists.
   5. `~/code/loop-review/loop-review post <clone> <number> <draft>`, with the clone's root as `<clone>`.
      - Success is exit 0, and its JSON gives the PR's URL for the report.
   - A failed step reports the PR as `failed` with the reason, leaves `reviews/` as it is, and the run goes on to the next PR.
   - The next run re-reviews a failed PR from scratch, since it has no pending review.
   - `permission_denials` are reported on the PR's line, and are never a failure on their own.
10. The report has one line per PR in queue order, `<number> <branch>: posted|skipped|failed`:
    - `posted` adds the pending review's URL, then `/review`'s closing line
    - `failed` adds the step, the reason, and the command to rerun that step by hand
    - any `permission_denials` follow on their own line
    - One closing line with the counts.
11. `queue.bash` prints one PR per line: number, branch and head sha, tab-separated.
12. `/review-bulk` stops and says so, touching nothing, if any of these holds:
    - `git status --porcelain` prints anything; untracked files count as dirty
    - `git check-ignore -q review.md` succeeds
    - `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
    - `~/code/loop-review/loop-review` is missing; `go build` in the clone makes it
    - `~/code/loop-review/reviews/` is missing
13. Both sessions run from the clone's root, and the run ends on the default branch, the one `origin/HEAD` points at.
