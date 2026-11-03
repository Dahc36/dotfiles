# Plan: loop-review

Idea: `idea.md`.

## Facts

- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line> <RIGHT|LEFT>`, with `<start>-<end>` for a range
  - `## Unsettled`
- `/review` anchors a finding on the touched line that caused it, a deleted line included.
- `Dahc36/dotfiles` is public.
- Skills and principles are symlinks into the dotfiles working tree; `aiprinciples` reads `principles/` and is linked at `~/bin/aiprinciples`.
- `claude -p "/<skill> <args>"` runs a user skill, even with `disable-model-invocation: true`, and passes the args as `$ARGUMENTS`.
- `--output-format json` returns `result`, `is_error`, `subtype`, `permission_denials`, `session_id` and `total_cost_usd`.
- `--disallowedTools` still denies under `bypassPermissions`, and the denial shows in `permission_denials`.
- `--disallowedTools` rules match command prefixes:
  - `Bash(gh api -X:*)` let `-XPOST`, `--method POST`, `-f` and a trailing `-X POST` through.
  - `Bash(gh:*)` denied `gh` by absolute path, through `env`, and after `cd . &&`.
- `--max-budget-usd` checks a client-side estimate at list prices: it spends no money and protects no usage limit.
- My Claude account is a Team seat with no usage credits:
  - its allowance resets on a 5-hour and a weekly window, shared with my own Claude use
  - `claude -p /usage` reads it at no cost
- From a real LaunchAgent, `claude` and `gh` authenticate through the keychain, with no dialog:
  - `claude`: `~/.local/bin/claude`
  - `gh`: `/opt/homebrew/bin/gh`, as `hans_fintual`
- macOS blocks LaunchAgents from `~/Documents`: scripts there fail with "Operation not permitted", and files there cannot be read.
  - A folder under `~/code` works.
- launchd's `StartInterval` skips a firing while the job still runs, and one while the Mac sleeps.
- `claude --resume <id>` works from any folder, even after the session's folder is deleted.
- Each session folder gets its own `~/.claude/projects/<path-with-dashes>/`, holding `<id>.jsonl` and a `memory/` folder.
- After a crash, re-adding the same worktree path fails until `git worktree remove --force` and `git worktree prune`.
- GitHub's GraphQL has what the runner needs:
  - `PullRequestReviewComment` has `line`, `startLine`, `body` and `lastEditedAt`.
  - `PullRequestReview` has `state`, `author`, `submittedAt`, `body` and `comments`.
- A deleted review comment disappears from `comments`, leaving no timestamp.
- GitHub allows one pending review per user per PR; a second one fails with a 422.
- Submitting a review removes me from `reviewRequests`; a re-request puts me back.
- `GET /repos/<owner>/<repo>/pulls/<n>/reviews` lists every review with its author and state.
  - Replying to a thread also creates a `COMMENTED` review.
- `flock` is released by the OS when its process dies, on macOS and Linux alike.
- `loop-review post <clone> <number> <draft.json>` posts the draft as my pending review, pinned to its `head`:
  - On success it prints one JSON object: the review's id, the PR's URL and each comment's id in draft order.
  - It refuses, with a non-zero exit, on a pending review of mine, on a PR head other than the draft's `head`, and on any invalid comment, naming each and the rule.

## Decisions

1. The record is `review.md`, kept outside the reviewed repo, plus the pending review on GitHub.
2. Every GitHub write is plain code, never a skill's.
3. The runner polls only the repos listed in `config.json`, never all of GitHub.
4. A poll reports a listed repo with no clone, or no `setup`, as an error, and goes on with the other repos.
5. The runner keeps its own state, per review run: the head sha it reviewed, and how far the run got.
   - Each poll reads GitHub for whether my review is pending or submitted, and whether the head moved.
   - When the two disagree, GitHub wins for whatever GitHub knows.
   - A submitted review is checked before whether the PR is closed, so a round I submitted goes to `comparing` even after a close or merge.
6. The state lives in SQLite, one row per review run.
   - The head sha each run reviewed is only in SQLite.
7. A run I have not submitted becomes `review stale` when its PR gets new commits, and reruns only when I ask.
8. A re-request after I submitted starts a new round on its own, as a new row.
   - It reviews the whole PR at the new head, without reading my earlier comments.
9. Each round's artifacts are flat files in `reviews/`:
   - `<repo>-<number>-<round>.review.md`
   - `<repo>-<number>-<round>.draft.json`
   - `<repo>-<number>-<round>.<step>.log`, one per step run
   - `<repo>-<number>-<round>.discrepancies.json`
   - The round is 1 plus my reviews on the PR not in `PENDING` state, and only keeps file names apart.
10. Cleanup:
    - A round's files and transcripts are deleted only from `discrepancies found`:
      - once `/review-improve` deletes its discrepancies file
      - at once, when `/review-compare` finds none
      - In every other state they stay until the PR is closed or merged.
    - When the PR is closed or merged with no review of mine submitted in the round, they are deleted in every state, runs in progress included.
    - A submitted round goes through `comparing` and `discrepancies found` as usual, closed or not.
    - A closed or merged PR's rows are deleted once nothing of it is left on the page.
11. `loop-review post` posts nothing when any comment breaks a rule, and the PR is `failed`, naming each invalid comment and the rule:
    - anchored on touched lines: added and context lines on `RIGHT`, removed lines on `LEFT`, every line of a range included
    - a `suggestion` block only on `RIGHT`, on a range GitHub can apply, and at most one per comment
    - every permalink into the reviewed repo resolves: the sha, the path at it and the line numbers
12. The summary and `Unsettled` are read on the page, never posted to GitHub.
13. `/review-compare` runs as a `claude -p` session like `/review` and `/review-draft`:
    - `--permission-mode auto`, and `--model` from `models` in `config.json`, defaulting to `opus`
    - `--disallowedTools` denying `git push`, `gh auth token` and `gh` entirely
    - a 10-minute timeout and a $2 spend cap, failing the PR when hit, naming the step and the limit
14. A PR on the page is in one of these states:

    | State                 | Meaning                                                  |
    | --------------------- | -------------------------------------------------------- |
    | `waiting for review`  | requests me, not started                                 |
    | `reviewing`           | `/review` running                                        |
    | `drafting`            | `/review-draft` running                                  |
    | `review ready`        | pending review posted                                    |
    | `review stale`        | new commits since the reviewed head                      |
    | `discarded`           | I discarded the pending review without submitting        |
    | `comparing`           | I submitted; `/review-compare` running                   |
    | `discrepancies found` | discrepancies file waiting for `/review-improve`         |
    | `failed`              | a step failed, with why and any denied tool calls        |

    - A PR that turns into a draft, or drops my request, after posting stays `review ready`.
    - A `discarded` PR is not queued again until a re-request after I submit, as in decision 8.
15. The page offers links and commands to copy, per state:

    | State                 | Links                                      | Commands                    |
    | --------------------- | ------------------------------------------ | --------------------------- |
    | `waiting for review`  | PR                                         |                             |
    | `reviewing`           | PR                                         |                             |
    | `drafting`            | PR, `review.md`                            |                             |
    | `review ready`        | PR files, `review.md`, draft               | redraft, re-review          |
    | `review stale`        | PR, `review.md`, draft                     | re-review                   |
    | `discarded`           | PR, `review.md`, draft                     | re-review                   |
    | `comparing`           | PR                                         |                             |
    | `discrepancies found` | PR, discrepancies                          | `/review-improve <path>`    |
    | `failed`              | PR, files where they exist                 | the failed step's rerun     |

    - `redraft` discards my pending review and reruns only `/review-draft`: `loop-review draft <clone> <number>`, with the head from the run's row, so the sha argument given by hand goes away.
    - `re-review` discards my pending review and reruns `/review` and `/review-draft`: `loop-review review <clone> <number>`.
    - `re-compare` reruns `/review-compare`.
    - `redraft` and `re-review` refuse when my pending review changed since it was posted, unless forced.
16. My pending review changed since it was posted when any of these holds:
    - a posted comment is missing
    - a comment was added
    - a comment has `lastEditedAt`
    - the body differs from the one posted
    - The run's row records the ids of the comments it posted.
17. One session runs at a time, across all repos and manual commands.
    - Every runner invocation holds a `flock` on `reviews/loop-review.lock`.
    - When it is held, a manual command refuses, naming the PR and step running, and a launchd poll exits silently.
    - At startup, holding it, any `reviewing`, `drafting` or `comparing` row becomes `failed`, "interrupted".
      - Its worktree is removed with `git worktree remove --force` and `git worktree prune`.
18. The queue is `/review-bulk`'s, per listed repo: open, non-draft PRs requesting me directly, oldest first.
19. launchd starts the runner every 15 minutes.
20. The page is `reviews/index.html`.
    - The runner rewrites it atomically on every state change.
    - It reloads itself every 30 seconds.
    - A running step shows when it started.
    - While the runner holds the lock, the page says so on top, naming the PR and step.
      - NOTE: manual commands refuse meanwhile.
    - A warning on top names the dotfiles paths holding runs back (decision 27).
21. The SQLite file lives in the runner clone, ignored by its `.gitignore` like `reviews/` and `config.json`.
    - The runner holds no company code or data; fixtures use made-up PRs.
22. When I submit a review, the skills improve from it:
    1. The runner fetches my submitted review: body and comments.
    2. `/review-compare` writes the round's discrepancies file, one entry per difference: a deleted, rewritten or added comment, or the body I wrote.
    3. With no discrepancies, the round's files are deleted and the PR leaves the page.
    4. Otherwise I run `/review-improve <path>` from dotfiles, copying the command from the page.
23. `/review-improve` is interactive, modeled on `/align-build`:
    1. It stops unless the dotfiles working tree is clean.
    2. We align on one commit's worth of improvement, dismissals included, one question at a time.
    3. It edits the skill files locally, following `aiprinciples prose`, and suggests a commit message; it never stages or commits.
    4. It removes that round's discrepancies from the file.
    5. It waits for me to commit, checks the tree is clean again, and goes on to the next round.
    6. It deletes the file once it is empty.
    - NOTE: the file holds only what is left, so a session can stop anywhere and resume later.
24. `/review-improve` keeps company content out of dotfiles:
    - skill edits and commit messages never carry repo names, PR numbers, identifiers or code from the reviewed repo
    - examples in a skill are made up, and each lesson is stated as a general rule
25. The two remaining skills live in dotfiles, next to `/review` and `/review-draft`:
    - `/review-compare` finds the discrepancies between my submitted review, `review.md` and the draft.
    - `/review-improve` turns the discrepancies into skill edits, with me.
26. Each `claude -p` session's id is recorded on its run's row, so cleanup (decision 10) can delete its transcript under `~/.claude/projects`.
27. Before each step, the runner checks the dotfiles paths it depends on against `main`:
    - the step's skill folder, `principles/` and the `aiprinciples` script
    - Uncommitted, untracked or not-on-`main` changes there hold every step back, and the page warns.
28. Before each session, the runner reads `claude -p /usage`, with a short timeout, and starts none above a configured usage:
    - 60% of the 5-hour window
    - 75% of the week
    - The output is prose: the runner matches the `Current session` and `Current week` lines by pattern, and takes the highest weekly percentage.
    - A missing line starts nothing, warns on the page, and the next poll retries.
    - A usage-limit error puts the PR back in its state before that step, and a poll after the reset retries it.
29. A review submitted on a PR `loop-review` never drafted is ignored.
30. The runner grows around `loop-review review`, and `/review-bulk` works throughout:
    1. The poller, SQLite, the page and the improvement steps.
    2. `/review-bulk` switches to `loop-review adopt <clone> <number> <review.md>`, after which the runner drafts, posts and tracks the PR like its own.
    - `/review-bulk` stays for the repos not listed.
31. Dotfiles moves to `~/code/dotfiles`, out of `~/Documents`, before the first unattended run.
    - Its symlinks are absolute, so every one breaks until `make link` runs from the new path:
      - shell configs, `~/.vimrc` and `~/.tmux.conf`
      - `~/bin/aiprinciples` and `~/bin/fzpath`
      - `~/.claude/settings.json`, `~/.claude/statusline.sh` and every skill's files
    - No tracked file hard-codes `~/Documents`; `scripts/link.bash` builds paths from `$PWD`.
    - Claude Code keys project memory by path, so this project's memory stays under the old path's folder in `~/.claude/projects` until it is moved too.
