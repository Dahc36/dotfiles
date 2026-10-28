---
name: refactor
description: Refactor the current change (or a given target) by applying all of my coding principles with judgment. Only when I invoke it, or when another skill delegates to it; never on your own initiative.
argument-hint: '[target files or directory]'
---

Refactor code by applying my coding principles.

## Principles

Read every `.md` file in `~/.claude/skills/principles/`. Each one describes a principle I want to follow and the reasoning behind it.

These are broad guidelines, not rules.
Apply them with nuance, in the context of the code being changed.
Understand the reasoning behind each principle and only make a change when it makes this particular code better.
Never apply a principle mechanically, and leave code alone when a change would not clearly improve it.
When principles conflict, prefer the simplest, clearest result for this specific case.

## Scope

- If `$ARGUMENTS` names files or directories, refactor those.
- Otherwise refactor the current change: the uncommitted diff (staged and unstaged). If there is none, use the diff of the current branch against the repository's default branch.
- If there is no target and no change, say so and stop.

Do not refactor unrelated code, unless required by changes within the scope.

## Process

1. Determine the scope and read the code in it, with enough surrounding context to understand it.
2. Edit the code directly.
3. Find the project's existing checks (tests, type checker, linter) from its config (e.g. `package.json`, `Makefile`, `pyproject.toml`, CI config). Run only the ones the change can make fail. Get them passing. That may mean fixing the refactor, or updating tests that no longer fit the new code.
4. Summarize:
   - each change made, with file location and the principle that motivated it
   - any changes to interfaces or behavior, and any tests changed or removed
   - the checks run and their results, or that none were found, or that none covers the scope
