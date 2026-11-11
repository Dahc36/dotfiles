# Building a whole alignment without supervising each commit

Finishing one PR with `/align-build` takes far longer than the work itself: each commit is a run I start and review.
The aim is every commit ready from one run, reviewed afterwards.

## Facts

- Skills are tracked in `src/.claude/skills/` and symlinked into `~/.claude/skills/`.
- The decision principles are the files printed by `aiprinciples decision`.
- `/decide` makes one choice from the decision principles, and records nothing.
- Git 2.50 is installed; `git rebase --update-refs` moves stacked branch pointers along during a rebase.
  - `rebase.updateRefs` is not set in my config.
- `/spec` writes the tech spec, which is committed and stays in the repo.
  - `Design` holds each decision with its reason.
  - `Changelog` is the flat list at its end.
- `/spec-build` builds the whole spec unattended, one commit at a time, onto one local branch per PR.
  - A surprise is a decision the spec did not make, or anything the spec got wrong; its `Surprises` section holds that rule.
  - At a surprise it takes the choice from `/decide`, corrects the body of the spec and appends a changelog entry.
    - An entry is what was found, with the reason for the choice nested under it.
    - It is committed with the code it describes.
  - A choice it makes without noticing the surprise gets no entry.
  - A rerun builds whatever the spec asks for and the branches lack.
  - It refuses to start while a rebase is in progress.
- `specbranch --list <spec path>` lists the branches of a spec's run.
- `/decide-fix` corrects one wrong decision wherever it lives, and knows nothing about specs or rebases.
  - For a built spec I run it at the decision's commit, where I stopped my interactive rebase with `edit`.
  - It leaves the correction uncommitted; amending the commit is mine.
  - It touches no later commit and no other branch.

## Decisions

1. The work is `/spec-propagate`, which carries a correction forward through the commits and branches after it.
   - `/align`, `/align-build`, `/align-plan` and `/pr-draft` stay as they are.
2. `/spec-propagate` settles what survives a correction, right after `/decide-fix` and while the rebase is still stopped.
   1. It reads the correction: the uncommitted diff, or how the amended commit differs from what it was.
   2. It judges each later commit of the rebase, and each other branch that contains the old commit:
      - keep: it neither touches what the correction changed nor relies on the old decision
      - drop: it was built on the old decision, and `/spec-build` builds it again
   3. It shows each verdict with its reason, and I change the ones I disagree with.
   4. On my go-ahead it applies them to the rest of the rebase and moves each dependent branch onto the rewritten commits.
   5. It ends by saying where things stand:
      - nothing was dropped, and no build is needed
      - or what was dropped, and that `/spec-build` is next once the rebase is finished
   - It refuses to start when no rebase is in progress.
3. I start it myself: it sets `disable-model-invocation`.
4. The work ships with no PR.

## Problems for later

- `/pr-draft` learns the why from the spec only on a branch whose diff touches it.
  - Revisit if drafts for later PRs in a stack come out with `(INFERRED)` reasons.
- A run stalls at a permission prompt when the session asks before running commands.
  - Choosing the permission mode is mine when I start a run; revisit once a real run shows where it stalls.
- Nothing notifies me when a run ends or refuses to start.
  - That is a hook in settings, useful for every long task.
