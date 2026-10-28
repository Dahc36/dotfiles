---
name: refactor-fix
description: Fix a refactoring I point at, iterating with me, then find the blind spot in my principles that let it exist and propose an improvement.
disable-model-invocation: true
argument-hint: '[file, file:line, identifier or a description of the smell]'
---

Fix the refactoring I point at, then improve my principles so that it does not happen again.

The principles are every file printed by `aiprinciples code prose`; each one describes a principle I want to follow and the reasoning behind it.

Never commit, in the project or in the principles.

## The fix

1. Pin down the target. `$ARGUMENTS` may name a file, a `file:line`, an identifier, or describe the smell. With none, ask one question: what am I looking at. Read the code with enough surrounding context to understand it.
2. Restate in one line what you take the target and the problem to be, and wait for my confirmation.
   1. NOTE: if it is a bug or a design problem rather than a refactoring, say so instead and stop.
3. Read the principles, then edit the code directly. Fix only the problem I pointed at and whatever that fix forces. The code you write follows the principles.
4. Run the project's checks (tests, type checker, linter), found from its config, with judgment. Say which ran, or why none did.
   1. NOTE: run only the ones the change can affect, and none for a change that confidently needs none: a comment change, a two-line rename, code no check covers.
5. Summarize what changed and why, and ask whether I am happy. Iterate from step 3 on my feedback until I am.

## The principles

1. Find the principle the issue falls under, if any.
2. When one covers it, name it and judge whether its wording would have caught this concrete code:
   - sharp enough: say so and stop
   - too abstract: propose sharpening it
3. When none covers it, propose an amendment to an existing principle or a new principle, whichever fits.
   1. NOTE: principles are not instructions
   2. NOTE: principles should distill the idea that leads to the right decision
   3. NOTE: principles should be language agnostic
   4. NOTE: examples can make a principle too rigid
4. A proposal is the exact text (the changed lines, or the whole new file) and the reasoning, in chat. Write it to `$(aiprinciples --dir)/<name>.md` only once I agree, after any adjustments.
   1. NOTE: it follows the shape of the existing files (`name:` and `tags:` frontmatter, a title, the reasoning, `##` sub-sections) and my prose principles.
5. End by offering to commit the change.
   1. Propose a commit message, it should be as short as possible.
   2. Once I agree to the message, commit the principle alone with it, as the whole message: no co-author or generated-by trailer.
