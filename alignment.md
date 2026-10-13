# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **Two habits to replace:** `git branch -l | fzf | xargs git checkout` and
  `git branch -l | fzf | xargs git branch -D`. Neither confirms; `-D` discards unmerged work.
- **Where own code lives today:** `src/bin/fzpath` (bash, `set -euo pipefail`), linked to
  `~/bin/fzpath`; `.zshenv` puts `~/bin` on `PATH` with the comment "scripts of my own live
  in ~/bin". `.zshrc` is tracked and sources oh-my-zsh with `plugins=(git)`; it holds no
  aliases or functions of its own. `.zprofile` is empty.
- **Not tracked:** `~/.gitconfig` (user, lfs, personal-account `includeIf` rules; no
  `[alias]` section) and `~/.oh-my-zsh/custom/` (only the stock `example.zsh`).
- **oh-my-zsh's git plugin** already defines `gb`, `gbd`, `gbD`, `gco`, `gcb`, `gsw`, so
  short names in that style are taken or near-taken.
- **Tools:** fzf 0.74.4 (`--multi`, `--preview`, `become`, `transform`), git 2.50.1.
- **Tests:** `tests/run.bash` runs bash suites per script (`add`, `diff`, `link`, `pull`,
  `restore`); scenarios stub `fzpath` on `PATH` rather than drive the real `fzf`.
  Nothing tests `.zshrc`.
- **fzf has no per-line "disabled" state.** `--header-lines=1` pins the first input line
  at the top, visible and unselectable; that is the idiomatic way to show the current
  branch without offering it. `--multi` enables tab selection.
- **Listing branches:** `git branch --format='%(refname:short)'` prints bare names with no
  `*` marker. For remotes, `%(refname:short)` collapses `origin/HEAD` to `origin`;
  `%(refname:lstrip=2)` keeps it as `origin/HEAD`, which can then be filtered out.

## Decisions

### D1 — Zsh functions in a new tracked file, sourced from `.zshrc`

Not a `bin/` script, not git aliases, not fzf key bindings. Interactive conveniences that
nothing else calls.

### D2 — The file is `src/.zsh/git.zsh`

Linked to `~/.zsh/git.zsh` by `make link`. `.zshrc` gains `source ~/.zsh/git.zsh`. Named by
topic, so later shell helpers get their own file beside it.

### D3 — The functions are `fzgco` (checkout) and `fzgprune` (delete)

`fz` prefix as in `fzpath`; no collision with oh-my-zsh's git plugin.

### D4 — `fzgco` lists local branches, with the current one pinned and unselectable

The current branch is the first line, shown through `--header-lines=1`; the rest are
local branches. A pick runs `git checkout <branch>`. Escape does nothing and prints nothing.
With a flag (name in D5), remote-tracking branches are appended to the list,
`origin/HEAD` excluded.

### D5 — `fzgco -a` adds remote branches; a remote pick checks out the short name

Remote entries show as `origin/foo`. Picking one strips the remote name and runs
`git checkout foo`, so git checks out an existing local `foo` or creates it tracking
`origin/foo`. One code path for both kinds of entries.

### D6 — `fzgprune` deletes several branches per run, multi-select on by default

Same list as `fzgco` without `-a`: local branches, current one pinned and unselectable.
`--multi` is always on: tab marks, enter deletes the marked set, and enter with nothing
marked deletes the highlighted line (fzf's default). No flag needed.

### D7 — `git branch -d` first; force only on a per-branch `y`

Each picked branch is tried with `git branch -d`. Merged branches go without a prompt.
When git refuses one as unmerged, its message is shown and the function asks
`Force delete <branch>? [y/N]`; `y` runs `git branch -D`, anything else leaves that
branch alone and moves on to the next.

### D8 — No preview pane

Both pickers are `git branch … | fzf` plus a few flags, nothing more.

### D9 — No README change, no tests

The README stays about the repo's tooling, as with `fzpath`. Zsh functions driving `fzf`
aren't covered by the bash harness; verification is running them by hand.
