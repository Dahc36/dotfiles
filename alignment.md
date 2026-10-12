# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **`scripts/select_differing.bash`** defines `select_differing`: lists tracked files whose
  `$HOME` counterpart is a differing regular file, as `~`-relative paths, pipes them to
  `fzf`, prints the pick. It checks for `fzf` and exits 1 naming it; on an empty list it
  prints "Nothing differs" and exits 0; Escape propagates `fzf`'s status.
- **`scripts/diff.bash`** is the model: the `src/` guard, then
  `source "${BASH_SOURCE[0]%/*}/select_differing.bash"` (relative to the script, because
  tests run it from a temp dir where `$PWD/scripts` doesn't exist), then
  `path=$(select_differing) || exit 1`.
- **Tests for a script using `select_differing`** run `git init` in the temp dir and commit
  `src/` first, because `git ls-files` only lists tracked files. `tests/diff/filter.bash`
  shows the shape, stub `fzf` included. `tests/run.bash` lists suites alphabetically.
- **`add` prints prose lines** like "Moving $dest > $src".

## Decisions

### D1 — `pull` copies the `$HOME` file over its tracked copy and stops

`scripts/pull.bash`, shaped like `diff.bash`: guard, source, pick, then
`cp "$HOME/$path" "src/$path"` and one line, "Pulled ~/<path> into src/<path>". Choosing
hunks, dropping the rest and committing are done with git by hand.

### D2 — `make pull`, a README bullet, and the `pull` suite

Makefile target `pull: bash $(SCRIPTS_DIR)/pull.bash`, added to `.PHONY`. README Commands
bullet: "`make pull` copies a `$HOME` file over its tracked copy", after `make diff`.
`tests/run.bash` gains `"pull"`.

Two scenarios in `tests/pull/`, each with its own git repo:

1. **dotfile** — stub `fzf` picks the differing file. Asserts exit 0, `src/` now matches
   home, home untouched.
2. **cancel** — stub exits 130. Asserts non-zero exit and `src/` unchanged.
