# Plan: loop-review

## Facts

- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line> <RIGHT|LEFT>`, with `<start>-<end>` for a range
  - `## Unsettled`
- `/review` anchors a finding on the touched line that caused it, a deleted line included.
- `Dahc36/dotfiles` is public.
- Dotfiles lives at `~/code/dotfiles`.
- Skills and principles are symlinks into the dotfiles working tree; `aiprinciples` reads `principles/` and is linked at `~/bin/aiprinciples`.
- `claude -p "/<skill> <args>"` runs a user skill, even with `disable-model-invocation: true`, and passes the args as `$ARGUMENTS`.
- `--output-format json` returns `result`, `is_error`, `subtype`, `permission_denials`, `session_id` and `total_cost_usd`.
- `--disallowedTools` still denies under `bypassPermissions`, and the denial shows in `permission_denials`.
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
- GitHub's GraphQL has what the runner needs:
  - `PullRequestReviewComment` has `line`, `startLine`, `body` and `lastEditedAt`.
  - `PullRequestReview` has `state`, `author`, `submittedAt`, `body` and `comments`.
- A deleted review comment disappears from `comments`, leaving no timestamp.
- GitHub allows one pending review per user per PR; a second one fails with a 422.
- Submitting a review removes me from `reviewRequests`; a re-request puts me back.
- `GET /repos/<owner>/<repo>/pulls/<n>/reviews` lists every review with its author and state.
  - Replying to a thread also creates a `COMMENTED` review.
- `loop-review post <clone> <number> <draft.json>` posts the draft as my pending review, pinned to its `head`:
  - On success it prints one JSON object: the review's id, the PR's URL and each comment's id in draft order.
  - It refuses, with a non-zero exit, on a pending review of mine, on a PR head other than the draft's `head`, and on any invalid comment, naming each and the rule.

## Decisions

1. The record is `review.md`, kept outside the reviewed repo, plus the pending review on GitHub.
2. Every GitHub write is plain code, never a skill's.
3. The runner polls only the repos listed in `config.json`, never all of GitHub.
4. A poll reports a listed repo with no clone, or no `setup`, as an error, and goes on with the other repos.
5. Each poll reads GitHub for whether my review is pending or submitted, and whether the head moved, and compares it with the run's row.
   - When the two disagree, GitHub wins for whatever GitHub knows.
6. A run I have not submitted becomes `review stale` when its PR gets new commits, and reruns only when I ask.
7. A re-request after I submitted starts a new round on its own, as a new row.
   - It reviews the whole PR at the new head, without reading my earlier comments.
8. Each round's artifacts are flat files in `reviews/`:
   - `<repo>-<number>-<round>.review.md`
   - `<repo>-<number>-<round>.draft.json`
   - `<repo>-<number>-<round>.<step>.log`, one per step run
   - The round is 1 plus my reviews on the PR not in `PENDING` state, and only keeps file names apart.
9. Cleanup:
   - A round's files and transcripts are deleted when I submit, or when the PR is closed or merged, runs in progress included.
   - A closed or merged PR's rows are deleted once nothing of it is left on the page.
10. `loop-review post` posts nothing when any comment breaks a rule, and the PR is `failed`, naming each invalid comment and the rule:
    - anchored on touched lines: added and context lines on `RIGHT`, removed lines on `LEFT`, every line of a range included
    - a `suggestion` block only on `RIGHT`, on a range GitHub can apply, and at most one per comment
    - every permalink into the reviewed repo resolves: the sha, the path at it and the line numbers
11. The summary and `Unsettled` are read on the page, never posted to GitHub.
12. A PR on the page is in one of these states:

    | State                 | Meaning                                                  |
    | --------------------- | -------------------------------------------------------- |
    | `waiting for review`  | requests me, not started                                 |
    | `reviewing`           | `/review` running                                        |
    | `drafting`            | `/review-draft` running                                  |
    | `review ready`        | pending review posted                                    |
    | `review stale`        | new commits since the reviewed head                      |
    | `discarded`           | I discarded the pending review without submitting        |
    | `failed`              | a step failed, with why and any denied tool calls        |

    - A PR that turns into a draft, or drops my request, after posting stays `review ready`.
    - A `discarded` PR is not queued again until a re-request after I submit, as in decision 7.
13. The page offers links and commands to copy, per state:

    | State                 | Links                                      | Commands                    |
    | --------------------- | ------------------------------------------ | --------------------------- |
    | `waiting for review`  | PR                                         |                             |
    | `reviewing`           | PR                                         |                             |
    | `drafting`            | PR, `review.md`                            |                             |
    | `review ready`        | PR files, `review.md`, draft               | redraft, re-review          |
    | `review stale`        | PR, `review.md`, draft                     | re-review                   |
    | `discarded`           | PR, `review.md`, draft                     | re-review                   |
    | `failed`              | PR, files where they exist                 | the failed step's rerun     |

    - `redraft` discards my pending review and reruns only `/review-draft`: `loop-review draft <clone> <number>`.
    - `re-review` discards my pending review and reruns `/review` and `/review-draft`: `loop-review review <clone> <number>`.
    - `redraft` and `re-review` refuse when my pending review changed since it was posted, unless forced.
14. My pending review changed since it was posted when any of these holds:
    - a posted comment is missing
    - a comment was added
    - a comment has `lastEditedAt`
    - the body differs from the one posted
15. A launchd poll exits silently when another `loop-review` holds the lock on `reviews/loop-review.lock`.
16. The queue is `/review-bulk`'s, per listed repo: open, non-draft PRs requesting me directly, oldest first.
17. launchd starts the runner every 15 minutes.
18. The page is `reviews/index.html`.
    - The runner rewrites it atomically on every state change.
    - It reloads itself every 30 seconds.
    - A running step shows when it started.
    - While the runner holds the lock, the page says so on top, naming the PR and step.
      - NOTE: manual commands refuse meanwhile.
    - A warning on top names the dotfiles paths holding runs back (decision 20).
19. The runner holds no company code or data; fixtures use made-up PRs.
20. Before each step, the runner checks the dotfiles paths it depends on against `main`:
    - the step's skill folder, `principles/` and the `aiprinciples` script
    - Uncommitted, untracked or not-on-`main` changes there hold every step back, and the page warns.
21. Before each session, the runner reads `claude -p /usage`, with a short timeout, and starts none above a configured usage:
    - 60% of the 5-hour window
    - 75% of the week
    - The output is prose: the runner matches the `Current session` and `Current week` lines by pattern, and takes the highest weekly percentage.
    - A missing line starts nothing, warns on the page, and the next poll retries.
    - A usage-limit error puts the PR back in its state before that step, and a poll after the reset retries it.
22. A review submitted on a PR `loop-review` never drafted is ignored.
23. The runner grows around `loop-review review`, and `/review-bulk` works throughout:
    1. The poller and the page.
    2. `/review-bulk` switches to `loop-review adopt <clone> <number> <review.md>`, after which the runner drafts, posts and tracks the PR like its own.
    - `/review-bulk` stays for the repos not listed.
