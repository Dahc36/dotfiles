---
name: review-bulk
description: Run /review and /review-draft on every open PR of this repo that requests my review directly, and post each draft as my pending review through loop-review post.
disable-model-invocation: true
model: opus
---

Review the PRs waiting on me in this repo, one at a time, and post each review as my pending review on GitHub, for me to edit and submit.

Takes no arguments. Nothing is committed or pushed. The only GitHub write is `loop-review post`; never post any other way, and never offer to.

## Paths

- `<clone>`: this repo's root, `git rev-parse --show-toplevel`.
  - Every command here runs from it.
- `<repo>`: the repo's name in `git remote get-url origin`, without `.git`.
- `reviews/`: `~/code/loop-review/reviews/`.
- A round's files, flat in `reviews/`:
  - `<repo>-<number>-<round>.review.md`
  - `<repo>-<number>-<round>.draft.json`

## Queue

`~/.claude/skills/review-bulk/queue.bash` prints it, one PR per line: number, branch and head sha, tab-separated. It lists the open, non-draft PRs of this repo that request my review directly, oldest first.

## My reviews on a PR

This prints the state of each of my reviews on the PR, `<me>` being `gh api user --jq .login`:

```
gh api --paginate 'repos/{owner}/{repo}/pulls/<number>/reviews' --jq '.[] | select(.user.login == "<me>") | .state'
```

- A `PENDING` review means the PR is skipped.
- The round is 1 plus the reviews not `PENDING`.

## Plan per PR

After `git fetch origin`, the first row that matches the PR decides its plan:

| PR                                                    | Plan     |
| ----------------------------------------------------- | -------- |
| my pending review on it                               | `skip`   |
| no `origin/<branch>`, the PR branch is gone           | `failed` |
| a local branch with a commit not on `origin/<branch>` | `failed` |
| anything else                                         | `review` |

- `skip` comes from my reviews alone, before any git command touches the branch.
- A local commit not on `origin/<branch>` is one `git rev-list origin/<branch>..refs/heads/<branch>` prints.
- `failed` is reported with the reason, and the branch is left untouched.
  NOTE: `/review-bulk` never destroys what it did not create.

## The sessions

`/review` and `/review-draft` each run as a `claude -p` session, launched as a background Bash command from `<clone>`. The next step waits for the command's exit notification.

`/review`, with the PR number:

```
claude -p "/review <number>" \
  --permission-mode auto --output-format json \
  --disallowedTools "Bash(git push:*)" "Bash(gh auth token:*)" "Bash(gh api:*)" \
    "Bash(gh pr review:*)" "Bash(gh pr comment:*)" "Bash(gh pr merge:*)" \
    "Bash(gh pr edit:*)" "Bash(gh pr close:*)" "Bash(gh pr create:*)" \
    "Bash(gh issue comment:*)" "Bash(gh issue create:*)" \
    "Bash(gh issue edit:*)" "Bash(gh issue close:*)"
```

`/review-draft`, with the round's `review.md` path and the head sha from the queue:

```
claude -p "/review-draft <review.md path> <head sha>" --model opus \
  --permission-mode auto --output-format json \
  --disallowedTools "Bash(git push:*)" "Bash(gh:*)"
```

- The output is JSON: read `is_error`, `subtype`, `permission_denials` and `result`.
- A session succeeds only when `subtype` is `success` and `is_error` is false.
- The deny rules match command prefixes, so they guard against accidents only.

## Reviewing one PR

1. `git checkout -B <branch> --track origin/<branch>`.
2. The `/review` session.
   - Success is both: the session succeeds, and `git status --porcelain` prints exactly `?? review.md`.
   - On anything else, `git checkout -- . && git clean -fd`.
3. Remove the round's old files from `reviews/`, if any, then move `review.md` to the round's `review.md` path.
4. The `/review-draft` session.
   - Success is both: the session succeeds, and the round's draft file exists.
5. `~/code/loop-review/loop-review post <clone> <number> <draft path>`.
   - Success is exit 0.
   - The `url` in its JSON is the PR's URL, for the report.

- A failed step makes the PR `failed`, with the reason, leaving `reviews/` as it is; the run goes on to the next PR.
  - The next run reviews a failed PR again from scratch, since it has no pending review.
- `permission_denials` are reported on the PR's line, and are never a failure on their own.

## Report

One line per PR in queue order, `<number> <branch>: posted|skipped|failed`:

- `posted` adds the pending review's URL, then `/review`'s closing line, the last line of its `result`.
- `failed` adds the step, the reason, and the step's command to rerun it by hand.
- Any `permission_denials` follow on their own line.

Then one closing line with the counts.

## Process

1. Stop and say so, touching nothing, if any of these holds:
   - `git status --porcelain` prints anything; untracked files count as dirty
   - `git check-ignore -q review.md` succeeds; `review.md` could never show up as untracked
   - `git symbolic-ref -q refs/remotes/origin/HEAD` fails; `git remote set-head origin -a` fixes it
   - `~/code/loop-review/loop-review` is missing; `go build` in `~/code/loop-review` makes it
   - `reviews/` is missing
2. Run the queue script, `git fetch origin`, and decide each PR's plan.
3. Print the queue, one line per PR with its plan, before the first session runs.
4. Review each PR whose plan is `review`, one at a time, in queue order.
5. Check out the default branch, the one `origin/HEAD` points at.
6. Print the report.
