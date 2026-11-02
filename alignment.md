# /review hands the checkout to its caller

## Facts

- `/review` writes `review.md` at the project root, after `gh pr checkout` and a clean-tree check.
- `review.md` has a fixed shape:
  - `# PR <number>: <title>`
  - `Intent` and `Implementation`
  - findings headed `## <n>. <BUG|QUALITY> <path>:<line>`
  - `## Unsettled`
- `/review` anchors a finding on the touched line that caused it, a deleted line included.
- A deleted line exists only on the `LEFT` side of the diff.
- `/review-bulk` runs `/review` in a subagent and relies on it to check out the branch and fast-forward it.
- The skills live in `src/.claude/skills/`, symlinked into `~/.claude/skills/`.

## Decisions

1. `/review` reviews whatever is checked out, and stops unless `HEAD` is the PR head.
   - It keeps its argument, a PR number, URL or branch, and compares that PR's `headRefOid` with `git rev-parse HEAD`.
   - It no longer runs `gh pr checkout`; its caller prepares the checkout.
   - Its other stop conditions stay: no argument, no open PR, a dirty tree, a `review.md` already there.
   - It leaves the checkout as it found it.
2. `/review` writes `review.md` at the checkout root, and its caller moves it out.
   - Success still means `git status --porcelain` prints exactly `?? review.md`.
3. `/review`'s finding header carries the side of the line, always and last: `## <n>. <BUG|QUALITY> <path>:<line> <RIGHT|LEFT>`.
   - A range, `<path>:<start>-<end>`, is on one side.
   - A fix for a deleted line goes in a regular fenced block, never a `suggestion` block.
4. `/review-bulk` prepares each branch's checkout itself, then runs the `/review` subagent on it.
   - Its branch plans keep their meaning: every plan that reviews ends with the branch checked out at `origin/<branch>` before the subagent starts.
   - The branch is still passed to the subagent as `/review`'s argument.
   - Its `review.md` commit stays.
