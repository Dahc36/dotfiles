# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **The habit to replace:** `git branch -l | fzf | xargs git branch -D`. It never confirms,
  and `-D` discards unmerged work.
- **`src/.zsh/git.zsh`** holds `fzgco`, sourced from `.zshrc`: the current branch from
  `git rev-parse --abbrev-ref HEAD` goes first and is pinned through fzf's
  `--header-lines=1`, then `git branch --format='%(refname:short)'` minus the current one,
  piped to `fzf --layout=reverse`. Escape returns fzf's status and does nothing.
- **fzf has no per-line "disabled" state**; `--header-lines=1` is the idiom. `--multi`
  enables tab marking, and enter with nothing marked outputs the highlighted line.
- **Tests:** `tests/run.bash` runs bash suites per script; nothing tests zsh.

## Decisions

### D1 — `fzgprune` deletes several branches per run, multi-select on by default

Lives beside `fzgco` in `src/.zsh/git.zsh`, with the same list: local branches, current
one pinned and unselectable. `--multi` is always on: tab marks, enter deletes the marked
set, and enter with nothing marked deletes the highlighted line. No flag, no preview.

### D2 — `git branch -d` first; force only on a per-branch `y`

Each picked branch is tried with `git branch -d`. Merged branches go without a prompt.
When git refuses one as unmerged, its message is shown and the function asks
`Force delete <branch>? [y/N]`; `y` runs `git branch -D`, anything else leaves that
branch alone and moves on to the next.

### D3 — No README change, no tests

The README stays about the repo's tooling, as with `fzpath`. Zsh functions driving `fzf`
aren't covered by the bash harness; verification is running them by hand.
