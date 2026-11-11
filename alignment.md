# Building a whole alignment without supervising each commit

Finishing one PR with `/align-build` takes far longer than the work itself: each commit is a run I start and review.
The aim is every commit ready from one run, reviewed afterwards.

## Facts

- Skills are tracked in `src/.claude/skills/` and symlinked into `~/.claude/skills/`.
- `/align-build` and `/pr-draft` read `alignment.md` by name at the project root.
  - `/pr-draft` takes a PR's why, decisions and manual steps from the shipping decision's sub-list.
  - `/pr-draft` pushes and opens nothing without my go-ahead.
- `/align-build` erases done work from `alignment.md`, so that file never holds history.
- The decision principles are the files printed by `aiprinciples decision`.
- `/decide` makes one choice from the decision principles, and records nothing.
  - It is given the question and what was found.
  - It returns the choice, its reason, and whether the principles settled it or left it open.
- `/pr-draft` takes the base branch as its argument, and stops when that base is not on origin.
- `/pr-draft` cannot be invoked by another skill: it sets `disable-model-invocation`.
- Git 2.50 is installed; `git rebase --update-refs` moves stacked branch pointers along during a rebase.
  - `rebase.updateRefs` is not set in my config.
- `/spec` writes the tech spec from `alignment.md`, which it replaces.
  - Its sections are `Context`, `Goals`, `Non-goals`, `Design`, `Plan` and `Changelog`, in that order.
  - `Design` holds each decision with its reason.
  - `Plan` is the ordered steps, each stating the checks that prove it is done, and says nothing about commits or PRs.
  - `Changelog` starts empty.
  - It commits nothing and creates no branch: it leaves the spec uncommitted, and `alignment.md` removed.
- `specbranch` names a run's branches from the spec's path:
  - `specbranch <spec path>` prints the prefix, the spec's file name without its extension
  - `specbranch <spec path> <last part>` prints the branch name, and refuses one git would not accept
  - `specbranch --list <spec path>` lists the run's existing branches

## Decisions

1. The work is these skills:
   - `/spec-build` builds the whole spec and never stops
   - `/decide-fix` corrects one wrong decision, then improves the principles
   - `/spec-propagate` carries a correction forward through the commits and branches after it
   - `/align`, `/align-build`, `/align-plan` and `/pr-draft` stay as they are.
2. The spec is committed and stays in the repo after the work merges.
   - Done work is never erased from it.
   - It carries no creation or edit date; git holds both.
3. `/spec-build` cuts the work into commits and PRs by itself, while building.
4. `Non-goals` bound what `/spec-build` may choose to build at a surprise.
5. A surprise is a decision the spec did not make, or anything the spec got wrong.
6. The spec does not track which steps are done.
   - `/spec-build` reads the spec and the code, and each step's checks confirm what is done.
   - A rerun is `/spec-build` run again: it builds whatever the spec asks for and the branches lack.
   - `/spec-build` never deletes commits or moves branches back.
7. At a surprise `/spec-build` gets the choice from `/decide`, corrects the body of the spec and adds a changelog entry.
   - The body always describes the code as built.
   - The run never stops.
   - Every edit to the body has an entry, which carries the reason the diff cannot.
8. The changelog is a flat list at the end of the spec, appended to in the order things happened.
   - An entry is what was found, with the reason for the choice nested under it.
   - The diff of the body carries what the spec assumed and what was chosen.
   - An entry names no part, no principle and no date.
   - Finding the principle is `/decide-fix`'s work.
9. A changelog entry is committed in the same commit as the code it describes.
   - Git ties the entry to its commit, so the spec names no hash or headline.
10. `/spec-build` states what must always hold for a PR; where to cut is a decision principle.
    - Each PR passes the project's checks on its own.
    - Each PR is based on the default branch or on another PR of the run, whichever its change needs.
    - PRs with a shared base and no need of each other are parallel branches.
    - The repo's own PR conventions win, found as `/pr-draft` finds them.
    - A cut is not a surprise and gets no changelog entry.
11. `/spec-build` divides the work into PRs and stops short of creating them.
    - A run ends with every commit made and one local branch per PR.
    - `/spec-build` pushes and posts nothing.
    - Its last message lists each branch with its base.
    - I review and rebase locally, then open each PR with `/pr-draft`, which stays as it is.
12. One `/spec-build` builds one commit at a time, and reads the state of its branches from git.
    - The branches of a run carry a prefix taken from the spec's file name, and `/spec-build` commits only on them.
    - Before choosing the next commit it reads each branch's base and what the branch holds over it.
    - The next commit is a branch and a change; a new branch also chooses which existing one it starts from.
    - It reads the spec as it is on the branch it is about to commit to.
13. Parallel branches that both add changelog entries conflict at the end of the spec, and that is accepted.
    - The second one to merge is rebased, keeping both entries.
14. For each commit `/spec-build` follows the process of `/align-build`, without its stops:
    1. Read the branches, then choose the next commit, following `Plan` order.
    2. Implement it, without reading the code principles yet.
    3. Run the project's checks and get them passing.
    4. Invoke `/refactor` on the uncommitted diff, the full pass every time, then run the checks again.
    5. Commit, with the spec's edits and changelog entries for that commit. The commit stands.
    6. Repeat until every step's checks pass.
15. `/spec-build` calls `/decide` wherever in the loop a surprise appears, and for where to cut a PR.
    - Recording the choice is `/spec-build`'s work.
16. A wrong decision is corrected at its commit, inside my interactive rebase.
    - I stop the rebase at the commit with `edit` and run `/decide-fix` there.
    - `/decide-fix` corrects that one decision in place and proposes the change to the principles, nothing more.
    - It follows the process of `/refactor-fix`:
      1. Pin down the decision: a changelog entry, or my description of a choice made silently in this commit.
      2. Restate the decision and what is wrong with it in one line, and wait for my confirmation.
      3. Correct the code, the spec's body and the changelog entry, touching only that decision and what it forces.
         - The entry keeps its finding, and its reason is rewritten for the new choice.
         - A silent decision gets the entry `/spec-build` should have written.
      4. Run the checks the change can affect.
      5. Iterate with me until I am happy.
      6. Leave the changes uncommitted; amending the commit is mine.
      7. Find what let the decision happen, and propose the exact change:
         - to the decision principles, when they lacked it or were too abstract
         - to `/spec-build`'s rule for what counts as a surprise, when the principles were fine and `/spec-build` missed one
      8. Offer to commit that change on its own.
17. `/spec-propagate` settles what survives a correction, right after `/decide-fix` and while the rebase is still stopped.
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
18. Principles change only through `/decide-fix`, during the spec as well as during the review.
    - Its target is a decision in a spec, built or not.
    - During the spec I point it at a choice I reject, or at a question the principles should have answered.
    - With no code yet, its code and checks steps have nothing to do.
19. A run starts from the spec's path, given as `/spec-build`'s argument; with none, it asks which file.
    - It refuses to start, touching nothing, when any of these holds:
      - the spec exists neither where I stand nor on a prefixed branch
      - the working tree holds anything but a spec as `/spec` leaves it
      - a rebase is in progress
      - the spec is committed and has uncommitted changes
    - A spec as `/spec` leaves it is either of these, and nothing else uncommitted:
      - the new spec, with a tracked `alignment.md` removed
      - the new spec alone, when `alignment.md` was never committed
    - When prefixed branches exist the run has started, and it resumes them whatever branch I am on.
      - The run's base is the commit those branches grew from.
    - When none exist, it creates the first prefixed branch from the commit it stands on, which becomes the base.
      - An uncommitted spec is the first commit on that branch, with the removal of `alignment.md` when there is one.
    - The branch I was on is left untouched.
    - Refusing to start is the only stop.
20. A branch is `<prefix>/<what the PR delivers>`, and `/spec-build` gets every name from `specbranch`.
21. I start every new skill myself.
    - `/spec-build`, `/decide-fix` and `/spec-propagate` set `disable-model-invocation`.
22. The work ships with no PR.

## Problems for later

- `/pr-draft` learns the why from the spec only on a branch whose diff touches it.
  - Revisit if drafts for later PRs in a stack come out with `(INFERRED)` reasons.
- A run stalls at a permission prompt when the session asks before running commands.
  - Choosing the permission mode is mine when I start a run; revisit once a real run shows where it stalls.
- Nothing notifies me when a run ends or refuses to start.
  - That is a hook in settings, useful for every long task.
