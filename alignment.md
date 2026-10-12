# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **Four tracked files, none linked on this machine.** Every `$HOME` counterpart is a
  regular file. `.tmux.conf` and `.vimrc` are identical to `src/`; `.zprofile` differs by
  14 lines and `.zshrc` by 73. `$HOME` is the newer side.
- **`make check` already answers "which files differ":** a differing regular file prints
  `replaced`, an identical one `adopted`. `make link` on a differing file would back up the
  `$HOME` version and link the repo's, the opposite of what's wanted here.
- **Git already does the rest.** `git diff --no-index src/.zshrc ~/.zshrc` shows the
  difference; `cp ~/.zshrc src/.zshrc` then `git add -p src/.zshrc` picks hunks to keep
  (`e` edits a hunk line by line), and `git restore src/.zshrc` drops the hunks not
  staged. Git 2.50.1, no difftool configured; `vimdiff` and `code` are on `PATH`.
- **Once linked, the question goes away:** a symlinked file can't drift from `src/`.
  This is a one-time catch-up per machine, plus any file `restore` put back.

## Decisions

### D1 — Scripts, not a README recipe

The recipe needs the same path typed twice per command. A script picks the tracked file
once, with `fzf`, and runs the commands with both paths.

### D2 — Two scripts: `diff` and `pull`

`scripts/diff.bash` shows how a tracked file differs from its `$HOME` counterpart.
`scripts/pull.bash` brings the `$HOME` version into `src/`. Each picks one file and does
one thing, like `link`, `add` and `restore`.

### D3 — The list is tracked files whose `$HOME` counterpart is a differing regular file

`git ls-files src`, keeping each entry only if `$HOME/<path>` is a regular file (not a
symlink, not missing) and `cmp -s` says it differs. Shown as `~`-relative paths, the form
`add` takes and `link` prints. An empty list prints "Nothing differs" and exits 0. The
same list in both scripts.

### D4 — `diff` answers "what would `make link` change on this machine"

`git diff --no-index "$HOME/<path>" src/<path>`: `$HOME` on the left as the current state,
`src/` on the right as what linking would make it, so `+` lines are what `link` brings in.
The other direction, what this machine has that the repo doesn't, is what `git diff` shows
after a `pull`, so `diff` doesn't need to cover it. Git's colour, pager and `diff.*`
settings apply. `git diff` exits 1 when the files differ; the script expects that and
exits 0.

### D5 — `pull` copies the whole file and stops

`cp "$HOME/<path>" src/<path>`, nothing else. Choosing hunks, dropping the rest and
committing are done with git by hand.

### D6 — `make diff` and `make pull`, one README bullet each

Both targets run `bash $(SCRIPTS_DIR)/<name>.bash` and join `.PHONY`. Commands bullets:
`make diff` shows what `make link` would change in a `$HOME` file; `make pull` copies a
`$HOME` file over its tracked copy. Nothing else in the README changes.

### D7 — The pick is shared: `scripts/select_differing.bash`, sourced by both

A file defining one function, `select_differing`, which lists tracked files whose `$HOME`
counterpart is a differing regular file (D3), pipes them to `fzf`, and prints the chosen
`~`-relative path or returns non-zero on cancel or an empty list. `diff.bash` and
`pull.bash` `source "$PWD/scripts/select_differing.bash"`, consistent with `$PWD`-based
root resolution. Not executable, no shebang, like `tests/utils.bash`. The two scripts stay
in lockstep by construction.

### D8 — Failure paths follow `restore`; `pull` prints one line

`select_differing` checks `command -v fzf` first and exits 1 naming it; Escape propagates
`fzf`'s status with no output; an empty list prints "Nothing differs" and exits 0. `diff`
prints only git's output. `pull` prints "Pulled ~/<path> into src/<path>", in `add`'s
prose style.

### D9 — Tests: suites `diff` and `pull`, four scenarios, each in its own git repo

`tests/run.bash` gains `diff` and `pull` in `test_suites`. Each scenario runs `git init`
in the temp dir and commits `src/` before calling the script, because `git ls-files` only
lists tracked files and the harness's temp dir is gitignored inside this repo.

1. **diff/filter** — tracked files whose home side is differing, identical, a symlink, or
   missing; a stub `fzf` saves its stdin and picks the differing one. Asserts the feed is
   exactly that one `~`-relative path, exit 0, and no file changed on either side.
2. **diff/nothing_differs** — all identical; a stub `fzf` that exits 2 if called. Asserts
   exit 0.
3. **pull/dotfile** — stub picks the differing file. Asserts `src/` now matches home and
   home is untouched.
4. **pull/cancel** — stub exits 130. Asserts non-zero exit and `src/` unchanged.
