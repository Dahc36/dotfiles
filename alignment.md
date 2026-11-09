# align-build commits, then resets

## Facts

- The skill lives at `src/.claude/skills/align-build/SKILL.md`, symlinked into `~/.claude/skills`.
- Its Scope says "Do not commit and do not stage. Committing is mine."
- Its last process step offers to commit with a short headline.
- The repo's commit convention is a short lowercase headline, at times prefixed with the skill name.

## Decisions

- The skill commits the step, then runs `git reset HEAD~1`.
  - The commit stays reachable as `ORIG_HEAD`; the change sits unstaged for me to decide on.
- The commit message is just a short headline that fits the repo's convention.
- The skill says nothing about whether `alignment.md` goes in the commit.
- If the commit fails, the skill says so and stops; hooks are never bypassed.
- The clean working tree guard stays as is.
- The Scope rule becomes: "Commit, then `git reset HEAD~1`. Whether the commit stands is mine."
- The process gets a step before the summary: "Commit with a short headline that fits the repo's convention, then `git reset HEAD~1`. If the commit fails, say so and stop."
- The summary names the headline and `git reset ORIG_HEAD` to bring the commit back, and offers nothing.
- Ships with no PR.
