# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **The want:** open a file changed in the current git worktree, tracked or untracked,
  picked with `fzf`.
- **Where helpers live:** `src/.zsh/git.zsh` holds `fzgco` and `fzgprune`, sourced from
  `.zshrc` under "shell functions of my own live in ~/.zsh". Both run `fzf --layout=reverse`,
  return silently on escape, and start with `git rev-parse` so a non-repo fails with git's
  own message. `src/bin/fzpath` is the one bash script, on `PATH` via `~/bin`.
- **Editor:** `$EDITOR` and `$VISUAL` are unset, `core.editor` is unset, the `.zshrc` block
  that would set `EDITOR` is commented out. `/usr/bin/vim` is installed; `nvim` is not.
  VS Code 1.141.1 is installed with its `code` CLI at `/usr/local/bin/code`; `code <files…>`
  opens them in the running window, `code -r` reuses it explicitly, `code -g file:line`
  jumps to a line.
- **oh-my-zsh's git plugin** defines `gd`, `gds`, `gdv` (diff into `view`), `gst`, `gsta`;
  nothing with an `fz` prefix.
- **Listing changes:** `git status --porcelain` prints one line per change with a two-column
  status, paths relative to the repo root whatever the cwd. Untracked directories collapse to
  `newdir/` unless `-uall`; deleted files appear as `D`; a staged rename prints
  `R "old" -> new`; paths with spaces are quoted unless `-z`. `git diff --name-only HEAD`
  lists tracked changes (staged or not, including deletions), root-relative.
  `git ls-files -o --exclude-standard --full-name` lists untracked files, root-relative.
  `git rev-parse --show-toplevel` gives the root to join them to.
- **Tools:** fzf 0.74.4 (`--multi`, `--preview`, `--tac`), git 2.50.1. `git diff` reads
  `color.ui`; `--color=always` forces colors into a preview pane.
- **Tests:** none cover zsh; the previous helpers were verified by hand.

## Decisions

### D1 — A zsh function `fzgcode` in `src/.zsh/git.zsh`

Next to `fzgco` and `fzgprune`. The name says the pick opens in VS Code's `code`.

### D2 — The list is every changed file, root-relative, deletions left out

Built from the repo root (`git rev-parse --show-toplevel`) so it works from any subdirectory:
tracked changes against HEAD, staged or not, from `git diff --name-only HEAD`; untracked
files, one per file rather than a collapsed directory, from
`git ls-files -o --exclude-standard`. Ignored files stay out. Deleted files stay out, there
being nothing to open; a staged rename lists its new path only.

### D3 — Multi-select on by default, all picks in one `code` call

`--multi` as in `fzgprune`: tab marks, enter opens the marked set, enter with nothing marked
opens the highlighted line. The picks go to a single `code` invocation, one tab each.

### D4 — No preview pane

As with `fzgco` and `fzgprune`: the list piped into `fzf` plus a few flags, nothing more.

### D5 — Picks go to `code` as absolute paths, no window flag

Each pick is joined to the repo root, so the call resolves from any subdirectory. No `-r`
or `-n`: `code <files…>` opens them in the last active window, or starts VS Code. Paths with
spaces stay whole, split on lines with `${(f)…}` as in `fzgprune`.

### D6 — An empty list prints `Nothing changed` and returns 1

No `fzf` with nothing to pick. Outside a repo, `git rev-parse` fails first with git's own
message, as in the siblings. Escape in `fzf` returns silently, as in the siblings.

### D7 — Tracked changes first, then untracked, plain paths in git's order

No sort or `--tac` flags, no status markers. Each block keeps git's alphabetical order.

### D8 — No README change, no tests; verified by hand

The README stays about the repo's tooling; the bash harness doesn't cover zsh. The build
sources the file and runs `fzgcode` in a repo with a staged change, an unstaged change, an
untracked file in a new directory and a deletion, from the root and from a subdirectory,
checking the list and that `code` opens the picks; then in a clean repo and outside one for
the two early exits. Commits: `align on fzgcode` for this file, then `add fzgcode`.
