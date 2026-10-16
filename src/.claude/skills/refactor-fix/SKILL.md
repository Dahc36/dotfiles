---
name: refactor-fix
description: Fix a refactoring I point at, iterating with me, then find the blind spot in my practices that let it exist and propose an improvement.
disable-model-invocation: true
argument-hint: '[file, file:line, identifier or a description of the smell]'
---

Fix the refactoring I point at, then improve my practices so that it does not happen again.

The practices are every `.md` file in `~/.claude/skills/practices/`; each one describes a practice I want to follow and the reasoning behind it.

Never commit, in the project or in the practices.

## The fix

1. Pin down the target. `$ARGUMENTS` may name a file, a `file:line`, an identifier, or describe the smell. With none, ask one question: what am I looking at. Read the code with enough surrounding context to understand it.
2. Restate in one line what you take the target and the problem to be, and wait for my confirmation.
   1. NOTE: if it is a bug or a design problem rather than a refactoring, say so instead and stop.
3. Read the practices, then edit the code directly. Fix only the problem I pointed at and whatever that fix forces. The code you write follows the practices.
4. Run the project's checks (tests, type checker, linter), found from its config, with judgment. Say which ran, or why none did.
   1. NOTE: run only the ones the change can affect, and none for a change that confidently needs none: a comment change, a two-line rename, code no check covers.
5. Summarize what changed and why, and ask whether I am happy. Iterate from step 3 on my feedback until I am.

## The practices

1. Find the practice the issue falls under, if any.
2. When one covers it, name it and judge whether its wording would have caught this concrete code:
   - sharp enough: say so and stop
   - too abstract: propose sharpening it
3. When none covers it, propose an amendment to an existing practice or a new practice, whichever fits.
4. A proposal is the exact text (the changed lines, or the whole new file) and the reasoning, in chat. Write it to `~/.claude/skills/practices/` only once I agree, after any adjustments.
   1. NOTE: it follows the shape of the existing files (`name:` frontmatter, a title, the reasoning, `##` sub-sections) and my `documenting` practice.
5. End with the code change, the checks run or skipped and why, and the practice change made or why none.
