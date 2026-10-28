---
name: worklog
description: Report what I worked on in a period, from my GitHub PRs, with the business value of each phrased for devs and for non-devs.
argument-hint: '[period, free text, default 8 days]'
disable-model-invocation: true
---

Report what I worked on in the period `$ARGUMENTS`, from my GitHub PRs.

The report is written to `worklog.md` at the root of the project, never committed, and `.gitignore` is not touched. Nothing is posted anywhere, and never offer to.

## Period

`$ARGUMENTS` is free text: `14d`, `2 weeks`, `since last Monday`, `2026-10-01`. Empty means the last 8 days. Resolve it to a start date.

## PRs

Every PR authored by me, in any repo, updated in the period:

```
gh search prs --author=@me --updated=">=<start date>" -L 200 \
  --json repository,number,title,state,isDraft,url,updatedAt
```

Any update counts, even a comment or a label from someone else: a PR only a bot touched is a PR left dangling, and the report must show it.

Then each PR in full:

```
gh pr view <number> -R <owner/repo> \
  --json title,body,state,isDraft,url,updatedAt,mergedAt,closedAt,commits,reviews,comments,closingIssuesReferences
```

## Entries

Sorted by `updatedAt`, most recent first.

PRs that share a purpose, the same title or the same linked ticket, are one entry: one value pair, every PR listed with its own link and status, sorted by the most recent PR of the group.

Each entry is a title, one bullet per PR with its status and last activity as sub-bullets, then the value:

```markdown
## 1. chore: bump turbo

- [web-app#3606](https://github.com/fintual/web-app/pull/3606)
  - merged
  - commit by you, 1d ago

- **Dev:** Upgrades Turbo to cut CI cache misses ...
- **Non-dev:** Developers wait less for changes to be checked ...
```

```markdown
## 2. Bump node v22.23.4 - CA Compromise

- [mobile-app#10223](https://github.com/fintual/mobile-app/pull/10223)
  - merged
  - approved by @tamara_fintual, 1d ago
- [design-system#3255](https://github.com/fintual/design-system/pull/3255)
  - merged
  - merged by you, 2d ago

- **Dev:** ...
- **Non-dev:** ...
```

Status is one of:

- `merged`
- `pending`, or `pending (draft)` when `isDraft`
- `closed`, for a PR closed without merging. Its value says what it tried to do and that nothing shipped.

Last activity is the newest of these, with who did it, me as `you`:

- a commit, `committedDate`
- a comment, `createdAt`
- a review, `submittedAt`, as `approved`, `changes requested` or `review comment` by its `state`
- the merge, `mergedAt`
- the close, `closedAt`

When the newest of those is more than a minute before `updatedAt` (a label, a rename, a force push by a bot), it is `other update`, with no author.

## Value

The value is why the PR exists for the business, not what it changes. Read these in order, and stop at the first that explains the why:

1. The title and body. Bodies follow a Context / Changelog / QA template, and Context usually says it.
2. What the body links to: issues (`gh issue view`), tickets, other PRs.
   - Slack: only when the body links a Slack conversation, and only that thread. Paraphrase it. Never copy names, RUTs, amounts or any personal data into the report.
3. The diff, `gh pr diff <number> -R <owner/repo>`, to infer the why from what changed.

When the why is still unclear after the three, write the best inference and end both phrasings with `(inferred)`, so I know which entries to check before sharing the report.

The two phrasings:

- `Dev:` what changed and why it matters, for someone who reads code. Names the mechanism.
- `Non-dev:` what someone who does not read code gets out of it: a client, the company, the team. No identifiers, no jargon.

Both are one or two sentences, in English. Identifiers and business terms that already exist in another language stay as they are.

## Process

1. Resolve the period to a start date.
2. Search the PRs, then read each one in full.
3. Group PRs that share a purpose, and sort.
4. Work out each entry's last activity and value.
5. Write `worklog.md`: `# Worklog <exact date range>`, e.g. `# Worklog Oct 15 – Oct 22`, a line with the count of PRs, then the entries.
6. Read `documenting.md` from my principles (`~/.claude/skills/principles/documenting.md`) and apply it to `worklog.md`.
7. End with one line: how many entries were written and that `worklog.md` is at the root, then offer to remove it. Remove it only when I say so.
