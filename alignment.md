# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

Verified by reading the scripts, Makefile, README, `tests/run.bash`, `tests/utils.bash` and
all 10 test files.

- **Repo shape.** 3 scripts (`link`, `add`, `restore`), a 5-target Makefile, 4 tracked
  dotfiles in `src/`, 14 tests across 3 suites. Single user, macOS.
- **bash is 3.2.57**, both `/bin/bash` and on PATH. No namerefs (`local -n`, 4.3+), no
  `declare -g` (4.2+).
- **`add` on a directory, then `link`, destroys the file — verified.** `add` doesn't check
  `-d`, so it moves a directory into `src/` and symlinks `$HOME` at it. On the next `link`,
  `walk_src` recurses into that directory and the destination resolves *through* the
  symlink back to the source, so `cmp -s "$src" "$dest"` compares a file with itself and
  reports identical. The identical-contents branch then `rm`s it and links it to itself:
  contents gone, no backup, and `cat` reports "Too many levels of symbolic links". It is
  the one branch that deletes without backing up first.

## Decisions

### D1 — `link` says where the backups went

After the walk, if the timestamped backup directory exists, print its path:

```bash
if [[ -d "$backup_path" ]]; then
  echo "Backed up files are in ${backup_path#"$PWD"/}"
fi
```

`backup_dest` creates it lazily, so its existence is the record of whether anything was
backed up — no counter needed, and nothing prints on a run that backed nothing up. Today
the per-file "Backing up …" lines never name the timestamped directory, so recovering
means going and looking for it.

### D2 — `add` is idempotent for an already-tracked file

Today the `-e "$src"` check fires first and reports `File …/src/.zshrc already exists` with
exit 1 — an error for a situation where nothing is wrong. `src/` already holding the file
covers two different situations, and they get different answers:

- **`src/<file>` exists and `~/<file>` is a symlink to it** — already tracked. Report it,
  exit 0. `add` becomes idempotent, like `link`.
- **`src/<file>` exists and `~/<file>` is a regular file or absent** — a real conflict: two
  versions and no way to know which is wanted. Exit 1, naming `make link` as what
  reconciles them, since that's the command that backs up the `$HOME` copy and links the
  tracked one.

### D3 — `add` rejects directories, and `link` refuses to act on a file that is its own target

Two fixes for the destruction path in the Facts above.

`add` checks `-d` and exits non-zero. There's no legitimate use for tracking a directory in
a repo whose linker walks per file, and adding one is what creates the state.

`link` checks `[[ "$src" -ef "$dest" ]]` — same inode — and refuses. Defence in depth: the
identical-contents branch is the only path that deletes without a backup, and it cannot
otherwise distinguish "a separate copy with identical contents" from "literally this file".
Anything else that produces the state — a hand-made symlink in `$HOME`, a restore gone
sideways — hits the same destruction without it.

### D4 — `restore` keeps `fzf`, checks for it, and refuses an empty selection

`fzf` stays: filtering beats scanning once backups accumulate, and bash's `select` lays its
menu out in columns, which is unreadable for a list of timestamps. It becomes a documented
requirement in the README, and `restore.bash` checks `command -v fzf` up front and exits
with a message naming it.

Three guards, all before anything destructive runs:

- **No `fzf`** — exit non-zero saying it's required.
- **No backups** — `backup/` empty or missing: say so and exit. Today `printf '%s\n'
  backup/*/` under `nullglob` prints one blank line, so `fzf` offers a single empty choice
  and an ordinary starting state walks into the bug below.
- **Empty selection** — exit non-zero. `walk_backup ""` globs `""/*` to `/*` and
  recursively walks the root filesystem, calling `rm "$HOME/<path>"` on paths derived from
  whatever it finds.

Cancellation is also made visible at the source. Today `local backup="$(… | fzf)"` masks
fzf's exit status behind the `local` declaration, and `${1:-$(select_backup)}` takes its
status from a trailing `echo` that always succeeds, so pressing Escape is indistinguishable
from choosing something. Declaring and assigning separately restores the status:

```bash
local backup
backup=$(printf '%s\n' "$PWD"/backup/*/ | fzf) || return 1
```

### D5 — `restore_file` stops aborting the run partway

Two guards, both against the same failure mode: `restore` giving up mid-recovery under
`set -e` and leaving a half-restored home directory with no record of what got through.

- **Don't `rm` a destination that isn't there.** Guard with `[[ -e $dest || -L $dest ]]`.
  Both tests are needed: `-e` follows symlinks and is false for a broken one, which is a
  state `link` can easily have left behind.
- **`mkdir -p` the destination's parent before `cp`.** A backup of a nested path is
  otherwise unrestorable once the intermediate directories are gone.

### D6 — `restore` puts files back and nothing else; the README says what that means

`restore` replaces the symlink with the backed-up file and leaves `src/` untouched, so the
next `make link` sees a differing regular file, backs it up and re-links — undoing the
restore. That stays the behaviour, and the README states it: the repo's version is
re-applied on the next `link` unless the file is removed from `src/` by hand.

`make check` reports the pending re-link as a `backed-up` line, so the state is
visible rather than waiting to surprise. Untracking stays manual; a command for it can come
later if it turns out to be a routine step.

### D7 — `restore` reports what it restored

`restore_file` runs silently today, so `make restore` returns to a prompt with no record of
what it touched. It prints one line per file in the shape of `link`'s `report` —
`printf '%-9s %s\n'` — so the three commands read consistently:

```
restored  ~/.zshrc
restored  ~/.config/nvim/init.lua
```

### D8 — README covers the decision table and the two gotchas

Three sections:

- **Decision table** — the eight outcomes `link` prints (`ok`, `linked`, `replaced`,
  `backed-up`, `relinked`, `repaired`, `skipped`, `ignored`) and what each means for the
  file. This is what the Commands section doesn't answer, and it's what you want to read
  before pointing this at a home directory: what happens when a real file is already at
  the target.
- **`fzf` is required** for `restore` (D4).
- **Restore doesn't stick** — the next `link` re-applies the repo's version unless the file
  is removed from `src/`, and `make check` shows it pending (D6).

### D9 — Test coverage

Eight new scenarios, in the shape of the existing fourteen: one file per scenario, a
`test_body` taking `tmp_dir` as `$1`, ending with `in_temp_dir test_body`.

**link**

1. `src` and `dest` are the same file — refused, file survives (D3)

**add**

2. Directory — refused (D3)
3. Already tracked — exit 0, nothing changes (D2)
4. `src/` has it but `$HOME` has a regular file — exit 1 (D2)

**restore**

5. Empty selection — exits without touching anything (D4)
6. No backups at all — exits with a message (D4)
7. Destination missing — restores it anyway (D5)
8. Nested path with missing parents — restores it anyway (D5)

1, 2 and 5 are the safety ones: 1 and 2 are the two halves of the verified data-loss path,
5 is the root-filesystem walk. No test for D1's backup-path message — asserting on output
text is brittle for little return.
