---
name: hone-skill
description: Improve a skill of mine from an outcome I did not want: diagnose the cause in its SKILL.md, propose the exact change as an edit to it, revert it unless I agree.
argument-hint: '[skill name and/or the undesired outcome]'
disable-model-invocation: true
---

Improve one of my skills from an outcome I did not want, so that it does not happen again.

My skills are the `SKILL.md` files under `~/.claude/skills/<name>/` (though they might be symlinks).
Only two things are written: the session's outcome, redone as agreed, and the `SKILL.md` being honed.
Only the `SKILL.md` is committed.

Questions come one at a time, each with your recommended answer.
What I need to see to answer goes inside the question, as the preview of each option; text outside the question goes unseen.
Facts you can look up, look up yourself.
Things you need my input with, ask me.

## The target

`$ARGUMENTS` may name a skill.
The current session, when there is one, is evidence of what the skill did.

- A skill named only by the session: confirm it with me in one line.
- No candidate at all: ask which skill.

Stop, touching nothing, when the skill is not in `~/.claude/skills/`.

## The diagnosis

Ask me relentlessly about the issue, until we have shared understanding of:

- what went wrong
- what a "right" outcome would look like

The change lands in the skill I invoked or in one it delegated to, whichever holds the cause.
If no wording would have prevented the issue, say so and stop.

When the session holds the outcome, redo it as the "right" one we agreed on.

## The change

Propose a change that guides the skill towards my desired outcome:

- it fixes the cause, not the symptom: it should describe what to do, rather than ban bad outcomes

The proposal is shown as before and after: the current lines of the `SKILL.md`, then the lines that replace them.
Iterate with me to confirm that the change reflects my intentions.

## Process

1. Pin down the skill, from `$ARGUMENTS` and the session.
   1. As soon as the skill is known, read its `SKILL.md` and those of every skill it delegates to.
2. Interrogate me to understand what went wrong.
3. Interrogate me to understand what "right" looks like.
4. Redo the session's outcome as the "right" one, when there is one.
5. Propose a change to the `SKILL.md`.
   1. Come up with a proposal.
   2. Read every file printed by `aiprinciples prose` and apply them.
   3. Ask for confirmation on the change
      1. If I'm not on board, go back to the corresponding step to correct the issue and keep going with the process
      2. Make the change
6. End by offering to commit the change.
   1. Propose a commit message, it should be as short as possible.
   2. Once I agree to the message, commit the `SKILL.md` alone with it, as the whole message: no co-author or generated-by trailer.
