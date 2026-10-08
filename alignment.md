# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

Verified by reading the scripts, Makefile, README, `tests/run.bash`, `tests/utils.bash` and
all 21 test files.

- **Repo shape.** 3 scripts (`link`, `add`, `restore`), a 5-target Makefile, 4 tracked
  dotfiles in `src/`, 21 tests across 3 suites. Single user, macOS.
- **bash is 3.2.57**, both `/bin/bash` and on PATH. No namerefs (`local -n`, 4.3+), no
  `declare -g` (4.2+).

## Decisions

### D1 — `restore` puts files back and nothing else; the README says what that means

`restore` replaces the symlink with the backed-up file and leaves `src/` untouched, so the
next `make link` sees a differing regular file, backs it up and re-links — undoing the
restore. That stays the behaviour, and the README states it: the repo's version is
re-applied on the next `link` unless the file is removed from `src/` by hand.

`make check` reports the pending re-link as a `backed-up` line, so the state is
visible rather than waiting to surprise. Untracking stays manual; a command for it can come
later if it turns out to be a routine step.

### D2 — README covers the decision table and the two gotchas

Three sections:

- **Decision table** — the nine outcomes `link` prints (`ok`, `linked`, `replaced`,
  `backed-up`, `relinked`, `repaired`, `skipped`, `ignored`, `refused`) and what each means
  for the file. This is what the Commands section doesn't answer, and it's what you want to read
  before pointing this at a home directory: what happens when a real file is already at
  the target.
- **`fzf` is required** for `restore`: `restore.bash` refuses to run without it.
- **Restore doesn't stick** — the next `link` re-applies the repo's version unless the file
  is removed from `src/`, and `make check` shows it pending (D1).
