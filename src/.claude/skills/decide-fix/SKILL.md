---
name: decide-fix
description: Correct a wrong decision I point at, iterating with me, then find what let it happen and propose an improvement to my decision principles.
disable-model-invocation: true
argument-hint: '[a record of the decision, file:line, or a description of the choice]'
---

Correct the decision I point at, then improve my decision principles so that it does not happen again.

The decision principles are every file printed by `aiprinciples decision`; each one describes a principle I want my decisions to follow and the reasoning behind it.

## The fix

1. Pin down the decision. `$ARGUMENTS` may name any of these:
   - a record of the decision, wherever it was written down
   - the code or text the decision produced
   - a choice made silently, which I describe
   - a question the principles left open and should have answered
   1. NOTE: with none, ask one question: which decision.
   2. NOTE: read what it points at with enough context to understand it.
2. Restate in one line what you take the decision and the problem with it to be, and wait for my confirmation.
   1. NOTE: a question the principles should have answered has nothing to correct: go straight to the principles.
3. Correct the decision wherever it lives: what it produced, and every record of it.
   - Touch only that decision and whatever the correction forces.
   - A record keeps what was found, and its reason is rewritten for the new choice.
   - A record follows the rules of whatever wrote it.
   - A silent decision gets the record it should have had, where those rules ask for one.
4. Run the project's checks (tests, type checker, linter), found from its config.
   - Say which ran, or why none did.
   1. NOTE: run only the ones the change can affect.
5. Summarize what changed and why, and ask whether I am happy.
   - Iterate from step 3 on my feedback until I am.
6. Leave the changes uncommitted: committing them is mine.

## The principles

1. Read the decision principles.
2. Find what let the decision happen, and propose the change that fits:
   - the principles lacked the idea that leads to the right choice
     - a new principle, or an amendment to an existing one
   - a principle held it, in wording too abstract to reach this concrete choice
     - a sharper wording of that principle
   - the principles were fine, and the choice was never put to them
     - a change to the rule that should have sent it there, in whatever made the choice
   1. NOTE: principles are not instructions
   2. NOTE: principles should distill the idea that leads to the right decision
   3. NOTE: examples can make a principle too rigid
3. A proposal is the exact text (the changed lines, or the whole new file) and the reasoning, in chat.
   - Write it only once I agree, after any adjustments.
   - A principle goes to `$(aiprinciples --dir)/<name>.md`.
   1. NOTE: it follows the shape of the existing files (`name:` and `tags:` frontmatter, a title, the reasoning, `##` sub-sections) and my prose principles, the files printed by `aiprinciples prose`.
4. End by offering to commit that change on its own.
   1. Propose a commit message, it should be as short as possible.
   2. Once I agree to the message, commit the change alone with it, as the whole message: no co-author or generated-by trailer.
