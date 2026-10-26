---
name: hone-skill
description: Improve a skill of mine from an outcome I did not want: diagnose the cause in its SKILL.md, propose the exact change as an edit to it, revert it unless I agree.
argument-hint: '[skill name and/or the undesired outcome]'
disable-model-invocation: true
---

Improve one of my skills from an outcome I did not want, so that it does not happen again.

My skills are the `SKILL.md` files under `~/.claude/skills/<name>/`. Nothing is written but the `SKILL.md` being honed, and nothing else is committed.

Questions come one at a time, each with your recommended answer. Facts you can look up (the skill, the skills it delegates to, the current session), look up; what you ask me is only what is in my head.

## The target

`$ARGUMENTS` may name a skill, describe the undesired outcome, or both. The current session, when there is one, is evidence of what the skill did.

- A skill named only by the session: confirm it with me in one line.
- No candidate at all: ask which skill.
- No outcome described: ask what happened and what I expected instead.

Stop, touching nothing, when the skill is not in `~/.claude/skills/`.

## The diagnosis

One line: the instruction that was followed or was missing, why it produced the outcome, and the behaviour I wanted. I confirm it before anything is proposed.

The change lands in the skill I invoked or in one it delegated to, whichever holds the cause. Two causes end with no change, said so and stop:

- an outcome no wording would have prevented

## The change

The smallest change that removes the cause:

- it fixes the cause, not the symptom: say what to do, and why when it is not obvious, rather than ban the one case that happened
- it goes where that behaviour is already described: a guard with the guards, a step in `## Process`, a definition in its section; never appended at the end
- it keeps the skill's shape and voice; a changed instruction is rewritten, never annotated
- it is written following `documenting.md` from my practices (`~/.claude/skills/practices/documenting.md`)

The proposal is an `Edit` call on the `SKILL.md`, on its target when it is a symlink, never a shell command, so that the change is shown as the diff that tool renders. Where the edit asks for permission, rejecting it is my no; where it lands first, a no from me reverts it with git. The same turn carries the reasoning and a replay in chat: the moment the skill went wrong, from the transcript or my description, walked through under the new wording until it reaches the behaviour I wanted, plus any other situation the change plausibly alters. Nothing is re-run; trying it again is mine.

## Process

1. Pin down the skill and the outcome, from `$ARGUMENTS` and the session. As soon as the skill is known, read its `SKILL.md` and those of every skill it delegates to, in full, before asking anything else.
2. Restate the diagnosis in one line and wait for my confirmation.
   1. NOTE: a cause in a practice, or an outcome no wording would have prevented: say so and stop.
3. Propose the change as an `Edit` on the `SKILL.md`, written as `documenting.md` would have it, with the reasoning and the replay. On my no, revert it with git before the next proposal; iterate until I agree.
4. End with one line: the file and lines changed, or why none, and the commit message in the repo's convention. Once I agree to the message, commit the `SKILL.md` alone with it.
