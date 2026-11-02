# Plan: loop-review

Idea: `idea.md`.

## Facts

- `/review` writes `review.md` at the project root, after `gh pr checkout` and a clean-tree check.
- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line>`
  - `## Unsettled`
- `/review` anchors a finding on the touched line that caused it, a deleted line included.
- `/review-bulk` commits each `review.md` on its PR branch, and that commit marks the PR as reviewed.
- `/review-check` reads `review.md` from that commit.
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
- `mise` is a shell function in interactive shells; the binary is `/opt/homebrew/bin/mise`, and its shims are in `~/.local/share/mise/shims`.
- A `claude -p` session's Bash gets my profile's functions, but its PATH from whoever launched it.
  - From a bare environment, `go` and `node` were missing, `ruby` was `/usr/bin/ruby`, and `aiprinciples` was not found.
- With decision 41's PATH, `gh` inside a bare-environment `claude -p` session authenticates as `hans_fintual`.
- `claude -p` skips the workspace trust dialog.
- `claude --resume <id>` works from any folder, even after the session's folder is deleted.
- Each session folder gets its own `~/.claude/projects/<path-with-dashes>/`, holding `<id>.jsonl` and a `memory/` folder.
- mise refuses a fresh worktree's `mise.toml` as not trusted; `MISE_TRUSTED_CONFIG_PATHS` on the parent folder fixes it.
- `git fetch origin <sha>` plus `git worktree add --detach` creates no ref, and `git worktree remove` leaves nothing behind.
- After a crash, re-adding the same worktree path fails until `git worktree remove --force` and `git worktree prune`.
- A worktree shares its clone's host ports, Docker volumes and databases:
  - monolith hard-codes its dev and test database names and Redis at `127.0.0.1:6379`
  - authorization-service, chat-service, core-banking, fintual-auth, fintual-auth-bff and stocks-pricing publish fixed host ports
  - stocks-broker pins its database volume's name
- Only mobile-app and design-system have open PRs requesting me directly.
- GitHub's GraphQL has what the runner needs:
  - `addPullRequestReviewThread` takes `line`, `startLine`, `side` and `startSide`.
  - `PullRequestReviewComment` has `line`, `startLine`, `body` and `lastEditedAt`.
  - `PullRequestReview` has `state`, `author`, `submittedAt`, `body` and `comments`.
- A deleted line exists only on the `LEFT` side of the diff.
- A deleted review comment disappears from `comments`, leaving no timestamp.
- GitHub allows one pending review per user per PR; a second one fails with a 422.
- Submitting a review removes me from `reviewRequests`; a re-request puts me back.
- `GET /repos/<owner>/<repo>/pulls/<n>/reviews` lists every review with its author and state.
  - Replying to a thread also creates a `COMMENTED` review.
- `flock` is released by the OS when its process dies, on macOS and Linux alike.

## Decisions

1. The record is `review.md`, kept outside the reviewed repo, plus the pending review on GitHub.
2. `/review-draft` turns `review.md` into the draft.
   - It carries my instructions on tone, language and how each problem is presented.
   - Comments are rewritten, not copied from the findings.
3. `/review-draft` writes a draft file, and `loop-review post` posts it as my pending review.
   - The draft file has one entry per comment.
   - Every GitHub write is plain code.
4. Each review runs in a throwaway worktree, detached at the PR head.
   - Setup runs from scratch every time, on purpose.
5. Worktrees share the clone's ports, volumes and databases, so only repos whose `setup` and tests stay off them are listed.
   - Making a repo safe to list is that repo's job; the runner adds no isolation.
   - The runner's README documents this limitation.
6. The runner polls only a configured list of repos, never all of GitHub.
7. Worktrees come from my working clone.
   - A listed repo with no clone is reported as an error, and the other repos go on.
8. Each list entry is a clone path, and `<owner>/<repo>` comes from its `origin`.
   - Two listed repos with the same name under different owners make the runner stop with an error.
   - Each entry must have a `setup` command, which the runner runs in each fresh worktree before `/review`.
   - An entry without `setup` is reported as an error, like a missing clone, and the other repos go on.
   - A failing `setup` makes the PR `failed`, naming the setup step.
9. The runner keeps its own state, per review run: the head sha it reviewed, and how far the run got.
   - Each poll reads GitHub for whether my review is pending or submitted, and whether the head moved.
   - When the two disagree, GitHub wins for whatever GitHub knows.
   - A submitted review is checked before whether the PR is closed, so a round I submitted goes to `comparing` even after a close or merge.
10. The state lives in SQLite, one row per review run.
11. A run I have not submitted becomes `review stale` when its PR gets new commits, and reruns only when I ask.
12. A re-request after I submitted starts a new round on its own, as a new row.
    - It reviews the whole PR at the new head, without reading my earlier comments.
13. `/review` reviews whatever is checked out, and stops unless `HEAD` is the PR head.
    - It no longer runs `gh pr checkout`; its caller prepares the checkout.
14. `/review` writes `review.md` at the checkout root, and its caller moves it out.
    - Success still means `git status --porcelain` prints exactly `?? review.md`.
15. Each round's artifacts are flat files in `reviews/`:
    - `<repo>-<number>-<round>.review.md`
    - `<repo>-<number>-<round>.draft.json`
    - `<repo>-<number>-<round>.discrepancies.json`
    - The round is 1 plus my reviews on the PR not in `PENDING` state, and only keeps file names apart.
    - A rerun within a round removes that round's old files before writing new ones.
    - The head sha each run reviewed is only in SQLite.
16. Cleanup:
    - A round's files and transcripts are deleted only from `discrepancies found`:
      - once `/review-improve` deletes its discrepancies file
      - at once, when `/review-compare` finds none
      - In every other state they stay until the PR is closed or merged.
    - When the PR is closed or merged with no review of mine submitted in the round, they are deleted in every state, runs in progress included.
    - A submitted round goes through `comparing` and `discrepancies found` as usual, closed or not.
    - A closed or merged PR's rows are deleted once nothing of it is left on the page.
17. `loop-review post` validates every comment before posting anything:
    - anchored on a touched line: added and context lines on `RIGHT`, removed lines on `LEFT`
    - `suggestion` blocks cover exactly their lines
    - no `suggestion` block on `LEFT`, where GitHub cannot apply it
    - links resolve
    - Any invalid comment means nothing is posted, and the PR is `failed`, naming each invalid comment and the rule.
18. `/review`'s finding header and the draft entry carry the side of the line.
    - A fix for a deleted line goes in a regular fenced block, never a `suggestion` block.
19. `/review-draft` checks each rewritten comment against its finding.
20. The draft has exactly one comment per finding: no dropping, no merging.
    - What goes into the review is decided by me, by deleting comments in "Files changed".
21. The summary and `Unsettled` are read on the page, never posted to GitHub.
22. The pending review's body stays empty; any overall comment I write when I submit.
23. `/review` and `/review-draft` run as two separate `claude -p` sessions.
    - `/review` runs in the worktree; `/review-draft` runs on the moved `review.md` and writes the draft file next to it.
    - `/review-draft` can rerun alone, without a new review.
24. Every `claude -p` session runs with `--permission-mode bypassPermissions`, plus `--disallowedTools` for GitHub writes.
    - Every session denies `git push` and `gh auth token`.
    - `/review` denies `gh api` entirely, plus the writing subcommands:
      - `gh pr review`, `comment`, `merge`, `edit`, `close` and `create`
      - `gh issue comment`, `create`, `edit` and `close`
    - Deny rules match command prefixes, so this guards against accidents only; `gh -R <repo> pr review` would get past it.
    - Unattended sessions read text others wrote, approve every tool call, and run with my credentials.
      - This exposure is accepted until the runner has a proper sandbox.
25. The runner lives in its own repo; the skills stay in dotfiles.
26. The runner is written in Go.
    - The repo is set up with mise.
27. A PR on the page is in one of these states:

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
    - A `discarded` PR is not queued again until a re-request after I submit, as in decision 12.
28. The page offers links and commands to copy, per state:

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

    - `redraft` discards my pending review and reruns only `/review-draft`.
    - `re-review` discards my pending review and reruns `/review` and `/review-draft`.
    - `re-compare` reruns `/review-compare`.
    - `redraft` and `re-review` refuse when my pending review changed since it was posted, unless forced.
29. My pending review changed since it was posted when any of these holds:
    - a posted comment is missing
    - a comment was added
    - a comment has `lastEditedAt`
    - the body is not empty
    - The run's row records the ids of the comments it posted.
30. A pending review of mine that the runner did not post makes the PR `failed` before `/review` starts, naming it.
31. One session runs at a time, across all repos and manual commands.
    - Every runner invocation holds a `flock` on `reviews/loop-review.lock`.
    - When it is held, a manual command refuses, naming the PR and step running, and a launchd poll exits silently.
    - At startup, holding it, any `reviewing`, `drafting` or `comparing` row becomes `failed`, "interrupted".
      - Its worktree is removed with `git worktree remove --force` and `git worktree prune`.
32. The queue is `/review-bulk`'s, per listed repo: open, non-draft PRs requesting me directly, oldest first.
33. launchd starts the runner every 15 minutes.
34. The page is `reviews/index.html`.
    - The runner rewrites it atomically on every state change.
    - It reloads itself every 30 seconds.
    - A running step shows when it started.
    - While the runner holds the lock, the page says so on top, naming the PR and step.
      - NOTE: manual commands refuse meanwhile.
    - A warning on top names the dotfiles paths holding runs back (decision 43).
35. The runner is a personal repo, `Dahc36/loop-review`, cloned at `~/code/loop-review`.
    - Not under `~/Documents`: macOS blocks launchd jobs from it.
    - It holds no company code or data; fixtures use made-up PRs.
    - `reviews/`, the SQLite file and the config live in the clone, ignored by its `.gitignore` from the first commit.
      - `reviews/` is always `~/code/loop-review/reviews/`, for the runner and for `/review-bulk` alike.
36. The runner, its repo and its binary are named `loop-review`.
37. When I submit a review, the skills improve from it:
    1. The runner fetches my submitted review: body and comments.
    2. `/review-compare` writes the round's discrepancies file, one entry per difference: a deleted, rewritten or added comment, or the body I wrote.
    3. With no discrepancies, the round's files are deleted and the PR leaves the page.
    4. Otherwise I run `/review-improve <path>` from dotfiles, copying the command from the page.
38. `/review-improve` is interactive, modeled on `/align-build`:
    1. It stops unless the dotfiles working tree is clean.
    2. We align on one commit's worth of improvement, dismissals included, one question at a time.
    3. It edits the skill files locally, following `aiprinciples prose`, and suggests a commit message; it never stages or commits.
    4. It removes that round's discrepancies from the file.
    5. It waits for me to commit, checks the tree is clean again, and goes on to the next round.
    6. It deletes the file once it is empty.
    - NOTE: the file holds only what is left, so a session can stop anywhere and resume later.
39. `/review-improve` keeps company content out of dotfiles:
    - skill edits and commit messages never carry repo names, PR numbers, identifiers or code from the reviewed repo
    - examples in a skill are made up, and each lesson is stated as a general rule
40. The three new skills live in dotfiles, next to `/review`:
    - `/review-draft` turns `review.md` into the draft file.
    - `/review-compare` finds the discrepancies between my submitted review, `review.md` and the draft.
    - `/review-improve` turns the discrepancies into skill edits, with me.
41. The runner gives every process it starts a working environment:
    - PATH starts with `~/bin`, `~/.local/share/mise/shims`, `/opt/homebrew/bin` and `~/.local/bin`.
    - `MISE_TRUSTED_CONFIG_PATHS` covers the folder holding the worktrees.
42. Each `claude -p` session's id is recorded on its run's row, so cleanup (decision 16) can delete its transcript under `~/.claude/projects`.
43. Before each step, the runner checks the dotfiles paths it depends on against `main`:
    - the step's skill folder, `principles/` and the `aiprinciples` script
    - Uncommitted, untracked or not-on-`main` changes there hold every step back, and the page warns.
44. Every process the runner starts has a timeout, and each session a spend cap too, all runaway guards:
    - `/review`: 45 minutes, $10
    - `/review-draft` and `/review-compare`: 10 minutes, $2 each
    - `setup`: a limit per list entry, with a default
    - `gh` calls and `claude -p /usage`: a short limit
    - Hitting any makes the PR `failed`, naming the step and the limit.
45. Before each session, the runner reads `claude -p /usage`, and starts none above a configured usage:
    - 60% of the 5-hour window
    - 75% of the week
    - The output is prose: the runner matches the `Current session` and `Current week` lines by pattern, and takes the highest weekly percentage.
    - A missing line starts nothing, warns on the page, and the next poll retries.
    - A usage-limit error puts the PR back in its state before that step, and a poll after the reset retries it.
46. The runner's config sets the model per skill, every one defaulting to `opus`.
    - `/review` drops its `model: opus` frontmatter; the runner passes `--model`.
      - A manual `/review` runs on the session's model, since frontmatter would beat `--model`.
47. Only `/review` uses `gh`, read-only, as `hans_fintual`; `/review-draft` and `/review-compare` have `gh` denied.
48. `gh` keeps a single account, `hans_fintual`, so the runner needs no account pinning.
49. A review submitted on a PR `loop-review` never drafted is ignored.
50. The work lands in two phases, and `/review-bulk` works throughout.
    1. Posting first:
       1. The `loop-review` repo starts with only `loop-review post <clone> <number> <draft.json>`: no polling, state, page or lock.
       2. `/review` changes as in decisions 13, 14 and 18.
       3. `/review-bulk`, per PR, checks out the branch in my clone, runs `/review`, moves `review.md` to `reviews/`, runs `/review-draft` and `loop-review post`.
          - It skips a PR on which I already have a pending review, and commits nothing.
       4. `/review-check` is deleted.
       - NOTE: no compare or improvement runs in this phase.
    2. The runner:
       1. The poller, SQLite, the page and the improvement steps grow around `loop-review post`.
       2. `/review-bulk` switches to `loop-review adopt <clone> <number> <review.md>`, after which the runner drafts, posts and tracks the PR like its own.
    - `/review-bulk` stays for the repos not listed.
51. Dotfiles moves to `~/code/dotfiles`, out of `~/Documents`, before the first unattended run.
    - Its symlinks are absolute, so every one breaks until `make link` runs from the new path:
      - shell configs, `~/.vimrc` and `~/.tmux.conf`
      - `~/bin/aiprinciples` and `~/bin/fzpath`
      - `~/.claude/settings.json`, `~/.claude/statusline.sh` and every skill's files
    - No tracked file hard-codes `~/Documents`; `scripts/link.bash` builds paths from `$PWD`.
    - Claude Code keys project memory by path, so this project's memory stays under the old path's folder in `~/.claude/projects` until it is moved too.
