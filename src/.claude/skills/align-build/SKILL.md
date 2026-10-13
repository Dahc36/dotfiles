---
name: align-build
description: Implement the next reasonable commit of the work agreed in alignment.md, then remove what was done from alignment.md. Only when I invoke it, or when another skill delegates to it; never on your own initiative.
---

Implement one commit's worth of the work agreed in `alignment.md`, so that each call leaves less pending.

`alignment.md` is the output of `/align`: a short list of facts and agreed decisions. The pending work is the gap between what it says and what the code does. Do not reopen the decisions in it.

## Scope

- `alignment.md` is always the one at the root of the opened project. If there is none, say so and stop.
- Work on exactly one commit: a coherent, reviewable change that stands on its own, with the code passing checks afterwards. Prefer foundations other steps depend on, then the smallest step that closes a whole item. Leave the rest for the next call.
- The working tree must be clean. Uncommitted changes, staged or unstaged, are unexpected: say so and stop without touching them.
- Do not commit and do not stage. Committing is mine.

## Process

1. Check `git status`; stop if the working tree is not clean. Read `alignment.md` and the relevant code to tell what is already done from what is pending.
2. Choose the next commit and state it in one line before starting.
3. If the step needs a decision `alignment.md` does not settle, ask me, one question at a time, with your recommended answer, as `/align` does. Facts you can look up, look up. Record the answer in `alignment.md` as a decision.
4. Implement the step. Edit the code directly, following the project's existing conventions. Aim for a working implementation. Do not read my coding practices yet.
5. Find the project's existing checks (tests, type checker, linter) from its config and run the relevant ones. Get them passing.
6. Only now, invoke the `refactor` skill through the Skill tool, with no arguments, so it runs on the uncommitted diff. It is the full pass every time, however small the step: every practice read fresh, every changed line reviewed. Then run the checks again and get them passing.
7. Update `alignment.md`:
   - Remove every fact and decision that only concerned the work now done. The code is the record of it from here on.
   - Keep facts and decisions that still matter for the remaining work, reworded if the done work changes how they read.
   - Add nothing about progress: no done sections, checkmarks, changelog or notes about this step. The file must read as if the done work had never been pending.
   - If nothing pending remains, delete `alignment.md` and say so.
8. Summarize:
   - the step done, with file locations
   - the checks run and their results, or that none were found
   - a suggested commit message, following the repo's convention or Conventional Commits
   - what remains in `alignment.md`, and what you would pick next
