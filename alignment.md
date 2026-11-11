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
- `specbranch` names a run's branches from the spec's path:
  - `specbranch <spec path>` prints the prefix, the spec's file name without its extension
  - `specbranch <spec path> <last part>` prints the branch name, and refuses one git would not accept
  - `specbranch --list <spec path>` lists the run's existing branches

## Decisions

1. The work is these skills:
   - `/spec` writes the tech spec from `alignment.md`
   - `/spec-build` builds the whole spec and never stops
   - `/decide-fix` corrects one wrong decision, then improves the principles
   - `/spec-propagate` carries a correction forward through the commits and branches after it
   - `/align`, `/align-build`, `/align-plan` and `/pr-draft` stay as they are.
2. The spec replaces `alignment.md`.
   - `/spec` removes `alignment.md` once the spec has resolved everything in it.
3. The spec file has a name of its own, not a generic one like `alignment.md` or `spec.md`.
   - The name is settled while the spec is written.
   - It is a tech spec, and owes nothing to the shape of `alignment.md`.
4. `/spec` asks where the spec is created.
5. The spec is committed and stays in the repo after the work merges.
   - Done work is never erased from it.
   - It carries no creation or edit date; git holds both.
6. The spec has the sections of a conventional design doc, in this order:
   - `Context`: why the work exists, and the facts the design relies on
   - `Goals`
   - `Non-goals`, which bound what `/spec-build` may choose to build at a surprise
   - `Design`: how it will work, each decision with its reason, in whatever sub-sections fit the work
   - `Plan`: the ordered steps
   - `Changelog`
7. `Plan` is the ordered breakdown of what needs to happen for the parts agreed in `Design` to be in place.
   - Each step states the checks that prove it is done.
   - `Plan` says nothing about commits or PRs.
   - `/spec-build` cuts the work into commits and PRs by itself, while building.
8. A surprise is a decision the spec did not make, or anything the spec got wrong.
9. The spec does not track which steps are done.
   - `/spec-build` reads the spec and the code, and each step's checks confirm what is done.
   - A rerun is `/spec-build` run again: it builds whatever the spec asks for and the branches lack.
   - `/spec-build` never deletes commits or moves branches back.
10. At a surprise `/spec-build` gets the choice from `/decide`, corrects the body of the spec and adds a changelog entry.
    - The body always describes the code as built.
    - The run never stops.
    - Every edit to the body has an entry, which carries the reason the diff cannot.
11. The changelog is a flat list at the end of the spec, appended to in the order things happened.
    - An entry is what was found, with the reason for the choice nested under it.
    - The diff of the body carries what the spec assumed and what was chosen.
    - An entry names no part, no principle and no date.
    - Finding the principle is `/decide-fix`'s work.
12. A changelog entry is committed in the same commit as the code it describes.
    - Git ties the entry to its commit, so the spec names no hash or headline.
13. `/spec-build` states what must always hold for a PR; where to cut is a decision principle.
    - Each PR passes the project's checks on its own.
    - Each PR is based on the default branch or on another PR of the run, whichever its change needs.
    - PRs with a shared base and no need of each other are parallel branches.
    - The repo's own PR conventions win, found as `/pr-draft` finds them.
    - A cut is not a surprise and gets no changelog entry.
14. `/spec-build` divides the work into PRs and stops short of creating them.
    - A run ends with every commit made and one local branch per PR.
    - `/spec-build` pushes and posts nothing.
    - Its last message lists each branch with its base.
    - I review and rebase locally, then open each PR with `/pr-draft`, which stays as it is.
15. One `/spec-build` builds one commit at a time, and reads the state of its branches from git.
    - The branches of a run carry a prefix taken from the spec's file name, and `/spec-build` commits only on them.
    - Before choosing the next commit it reads each branch's base and what the branch holds over it.
    - The next commit is a branch and a change; a new branch also chooses which existing one it starts from.
    - It reads the spec as it is on the branch it is about to commit to.
16. Parallel branches that both add changelog entries conflict at the end of the spec, and that is accepted.
    - The second one to merge is rebased, keeping both entries.
17. For each commit `/spec-build` follows the process of `/align-build`, without its stops:
    1. Read the branches, then choose the next commit, following `Plan` order.
    2. Implement it, without reading the code principles yet.
    3. Run the project's checks and get them passing.
    4. Invoke `/refactor` on the uncommitted diff, the full pass every time, then run the checks again.
    5. Commit, with the spec's edits and changelog entries for that commit. The commit stands.
    6. Repeat until every step's checks pass.
18. `/spec-build` calls `/decide` wherever in the loop a surprise appears, and for where to cut a PR.
    - Recording the choice is `/spec-build`'s work.
19. A wrong decision is corrected at its commit, inside my interactive rebase.
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
20. `/spec-propagate` settles what survives a correction, right after `/decide-fix` and while the rebase is still stopped.
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
21. `/spec` settles the detail `alignment.md` leaves open: what the principles settle it decides, the rest it asks me.
    - It lists the details the build needs, and calls `/decide` for each.
    - A clear answer from the principles goes into the spec, stated to me with its reason.
    - Anything else is a question to me, one at a time with a recommendation, saying the principles did not settle it.
22. Principles change only through `/decide-fix`, during the spec as well as during the review.
    - Its target is a decision in a spec, built or not.
    - During the spec I point it at a choice I reject, or at a question the principles should have answered.
    - With no code yet, its code and checks steps have nothing to do.
23. A run starts from the spec's path, given as `/spec-build`'s argument; with none, it asks which file.
    - It refuses to start, touching nothing, when any of these holds:
      - the spec exists neither where I stand nor on a prefixed branch
      - the working tree is not clean
      - a rebase is in progress
      - the spec is not committed, or has uncommitted changes
    - When prefixed branches exist the run has started, and it resumes them whatever branch I am on.
      - The run's base is the commit those branches grew from.
    - When none exist, because I committed the spec myself, it creates the first prefixed branch from the commit it stands on, which becomes the base.
    - The branch I was on is left untouched.
    - Refusing to start is the only stop.
24. `/spec` ends by creating the run's first branch and offering one commit on it.
    1. It writes the spec to the place and name I chose, following the prose principles.
    2. It checks that the spec resolves every fact and decision of `alignment.md`, and names any it does not.
    3. It removes `alignment.md` once nothing is left unresolved.
    4. It creates the first prefixed branch from the commit I stand on.
    5. It offers one commit that adds the spec and removes `alignment.md`, with a headline that follows the repo's conventions.
    - Nothing is pushed.
25. A branch is `<prefix>/<what the PR delivers>`, and `/spec` and `/spec-build` get every name from `specbranch`.
    - `/spec-build` names a branch after what its PR delivers.
    - `/spec` names the first branch after the first step of `Plan`.
26. I start every new skill myself.
    - `/spec`, `/spec-build`, `/decide-fix` and `/spec-propagate` set `disable-model-invocation`.
27. The work ships with no PR.

## Problems for later

- `/pr-draft` learns the why from the spec only on a branch whose diff touches it.
  - Revisit if drafts for later PRs in a stack come out with `(INFERRED)` reasons.
- A run stalls at a permission prompt when the session asks before running commands.
  - Choosing the permission mode is mine when I start a run; revisit once a real run shows where it stalls.
- Nothing notifies me when a run ends or refuses to start.
  - That is a hook in settings, useful for every long task.
