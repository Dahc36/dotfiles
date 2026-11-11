# Building a whole spec without supervising each commit

`/spec-build` builds every commit of a tech spec in one run, and I review afterwards.
What follows was left out of that work.

## Facts

- `/spec` writes the tech spec, which is committed and stays in the repo.
- `/spec-build` builds the whole spec unattended, onto one local branch per PR.

## Problems for later

- `/pr-draft` learns the why from the spec only on a branch whose diff touches it.
  - Revisit if drafts for later PRs in a stack come out with `(INFERRED)` reasons.
- A run stalls at a permission prompt when the session asks before running commands.
  - Choosing the permission mode is mine when I start a run; revisit once a real run shows where it stalls.
- Nothing notifies me when a run ends or refuses to start.
  - That is a hook in settings, useful for every long task.
