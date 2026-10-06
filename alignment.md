# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

Verified by reading the scripts, Makefile, README, `tests/run.bash`, `tests/utils.bash` and
all 10 test files.

- **Repo shape.** 3 scripts (`link`, `add`, `restore`), a 4-target Makefile, 4 tracked
  dotfiles in `src/`, 10 tests across 3 suites. Single user, macOS.
- **bash is 3.2.57**, both `/bin/bash` and on PATH. No namerefs (`local -n`, 4.3+), no
  `declare -g` (4.2+).
- **The already-linked branch in `sync_src` is a backup-churn guard, not a self-link
  guard.** Without it, `backup_dest` moves the existing symlink into `backup/` and
  `link_dest` then creates a correct link. The outcome is right; the cost is a junk backup
  directory on every run.
- **`add` on a directory, then `link`, destroys the file — verified.** `add` doesn't check
  `-d`, so it moves a directory into `src/` and symlinks `$HOME` at it. On the next `link`,
  `walk_src` recurses into that directory and the destination resolves *through* the
  symlink back to the source, so `cmp -s "$src" "$dest"` compares a file with itself and
  reports identical. The identical-contents branch then `rm`s it and links it to itself:
  contents gone, no backup, and `cat` reports "Too many levels of symbolic links". It is
  the one branch that deletes without backing up first.

## Decisions

### D1 — `link` skips expected conditions, aborts on real failures

`set -e` stays. A failed `ln` or `mv` aborts the walk, as today: those need manual
intervention before a re-run would help, they're usually systemic so one fix clears them
all, and `link` is idempotent — already-linked files return early — so re-running after the
fix is cheap and safe. No failure counting, no status plumbing through `walk_src`.

Two conditions are not failures and don't stop the walk:

**A directory at the target path** — report and skip. Today nothing checks `-d "$dest"`, so
`cmp -s` fails against a directory, control falls through to `backup_dest`, and the whole
directory tree is `mv`'d into `backup/` and replaced by a symlink.

The reason to refuse it is that `link` can back a directory up but `restore` can't bring it
back. `restore_file` rebuilds paths under `$HOME` file by file, and by then `~/.vimrc` is a
symlink to a regular file, so there's nowhere for `~/.vimrc/colors/x.vim` to land and
`mkdir -p` can't create it either. Files round-trip; directories go in and don't come out.
Skipping keeps `restore` file-only by design instead of building recovery for a case that
shouldn't arise.

Aborting instead of skipping would let one stray directory in `$HOME` block every remaining
dotfile indefinitely, since that's a normal state for a home directory to be in.

**`.DS_Store` in `src/`** — `walk_src` skips it, and it goes in `.gitignore`. macOS writes
it into any directory opened in Finder, so it's the one file that can appear in `src/`
without being put there. With `dotglob` on it would otherwise be linked into `$HOME`, after
which Finder writes through the symlink into `src/.DS_Store` and the repo shows churn in a
file nobody touched.

### D2 — `link` exits 0; a `--dry-run` mode backs a `check` command

`link` exits 0 when it completes, including when it skipped something. Skips are deliberate
outcomes and are reported on screen, and a non-zero exit would need `sync_src` to return a
status and `walk_src` to carry it up through the recursion — machinery with nothing
consuming it, since nothing here is automated.

`link.bash` takes `--dry-run`: it walks `src/` and reports what it *would* do for every
file — linked, absent, identical file in the way, differing file in the way, foreign
symlink, broken symlink, directory in the way — without running any `mkdir`, `ln`, `mv` or
`rm`. It exits 0 too: it's a display, and nothing consumes an exit code from it.

`make check` passes the flag. No separate `scripts/check.bash` — `make` is the entry point,
so a target is the whole interface.

One walk, one decision table, so the reported state can't drift from the acted-on state.
It also gives a way to preview the run before pointing `link` at a home directory for the
first time.

Scope is the state of `src/`'s targets in `$HOME`, not a search for untracked dotfiles in
`$HOME` that might be worth adding — that's a different job with no natural boundary.

### D3 — `link` says where the backups went

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

### D4 — One status token per case, aligned, one line per file

`link` and `check` print a fixed-width token and a path — no prose, no parentheticals:

| token | case |
| --- | --- |
| `ok` | already linked, nothing done |
| `linked` | target was absent |
| `replaced` | identical file removed, symlink put in its place |
| `backed-up` | differing file moved to `backup/`, symlink created |
| `relinked` | symlink pointed elsewhere, moved to `backup/`, symlink created |
| `repaired` | symlink was broken, moved to `backup/`, symlink created |
| `skipped` | directory in the way (D1) |
| `ignored` | `.DS_Store` in `src/` (D1) |

`printf '%-9s %s\n'` aligns the column — `backed-up` is the longest at nine. Paths print as
`~/…`, except `ignored`, which prints the `src/` path since it's the source file being
refused rather than a target being declined.

`relinked` and `repaired` take the same action and are split anyway, so the state that was
found is readable from the token alone. A `relinked` symlink's old target stops being
printed; it's preserved in `backup/`.

A stable first token makes the output greppable — `make check | grep -v '^ok'` is the
question you actually want answered.

`--dry-run` prints the same tokens for what would happen, so the two modes read identically.

### D5 — `mkdir -p` moves into `link_dest`

Today it sits only in the target-absent branch of `sync_src`; the other branches work
because something already exists at `dest`, so its parent must too — a precondition nothing
states. Unconditional in `link_dest` is uniformly correct, `mkdir -p` being a no-op when
the directory exists, and it pairs the two halves of one operation. It also gives
`--dry-run` a single mutation to suppress instead of two in different places.

### D6 — `sync_src` nests the symlink cases instead of flattening them

The already-linked check moves inside the "destination is a symlink" branch:

```bash
if [[ -L "$dest" ]]; then
  if [[ "$(readlink "$dest")" == "$src" ]]; then
    report ok "$dest"
    return
  fi

  if [[ -e "$dest" ]]; then
    report relinked "$dest"
  else
    report repaired "$dest"
  fi

  backup_dest "$dest"
  link_dest "$src" "$dest"
  return
fi
```

As two flat guards, the first reads like a fast path for something the second already
handles — and in end state it is. The difference is a side effect: without it, a correct
symlink gets `mv`'d into `backup/` and recreated identically, so every run leaves another
timestamped directory containing nothing but symlinks, burying the one backup that holds a
real file. Nested, the early return can't be removed without reading the `backup_dest` that
would then run on a symlink just confirmed correct.

`-e` follows the link, so `-e "$dest"` being false is exactly "broken" — D4's
`relinked`/`repaired` split falls out of code that has to exist anyway.

Top level then reads as "what is at the destination": a symlink, nothing, or a file, with
the symlink case owning its sub-cases.

### D7 — Comment the `shopt` lines with what depends on them

`walk_src` is only correct because `dotglob` and `nullglob` are set fifty lines above it.
Without `dotglob` the glob stops matching `.zshrc` and the rest, and a dotfiles manager
silently sees nothing and exits 0. They stay at the top as script-wide settings, with a
comment naming `walk_src` as the dependant.

### D8 — `add` is idempotent for an already-tracked file

Today the `-e "$src"` check fires first and reports `File …/src/.zshrc already exists` with
exit 1 — an error for a situation where nothing is wrong. `src/` already holding the file
covers two different situations, and they get different answers:

- **`src/<file>` exists and `~/<file>` is a symlink to it** — already tracked. Report it,
  exit 0. `add` becomes idempotent, like `link`.
- **`src/<file>` exists and `~/<file>` is a regular file or absent** — a real conflict: two
  versions and no way to know which is wanted. Exit 1, naming `make link` as what
  reconciles them, since that's the command that backs up the `$HOME` copy and links the
  tracked one.

### D9 — `add` rejects directories, and `link` refuses to act on a file that is its own target

Two fixes for the destruction path in the Facts above.

`add` checks `-d` and exits non-zero. There's no legitimate use for tracking a directory in
a repo whose linker walks per file, and adding one is what creates the state.

`link` checks `[[ "$src" -ef "$dest" ]]` — same inode — and refuses. Defence in depth: the
identical-contents branch is the only path that deletes without a backup, and it cannot
otherwise distinguish "a separate copy with identical contents" from "literally this file".
Anything else that produces the state — a hand-made symlink in `$HOME`, a restore gone
sideways — hits the same destruction without it.

### D10 — `restore` keeps `fzf`, checks for it, and refuses an empty selection

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

### D11 — `restore_file` stops aborting the run partway

Two guards, both against the same failure mode: `restore` giving up mid-recovery under
`set -e` and leaving a half-restored home directory with no record of what got through.

- **Don't `rm` a destination that isn't there.** Guard with `[[ -e $dest || -L $dest ]]`.
  Both tests are needed: `-e` follows symlinks and is false for a broken one, which is a
  state `link` can easily have left behind.
- **`mkdir -p` the destination's parent before `cp`.** A backup of a nested path is
  otherwise unrestorable once the intermediate directories are gone.

### D12 — `restore` puts files back and nothing else; the README says what that means

`restore` replaces the symlink with the backed-up file and leaves `src/` untouched, so the
next `make link` sees a differing regular file, backs it up and re-links — undoing the
restore. That stays the behaviour, and the README states it: the repo's version is
re-applied on the next `link` unless the file is removed from `src/` by hand.

`make check` (D2) reports the pending re-link as a `backed-up` line, so the state is
visible rather than waiting to surprise. Untracking stays manual; a command for it can come
later if it turns out to be a routine step.

### D13 — `restore` reports what it restored

`restore_file` runs silently today, so `make restore` returns to a prompt with no record of
what it touched. It prints one line per file in D4's shape — `printf '%-9s %s\n'` — so the
three commands read consistently:

```
restored  ~/.zshrc
restored  ~/.config/nvim/init.lua
```

### D14 — `check` Makefile target

Add **`check`**, running `bash $(SCRIPTS_DIR)/link.bash --dry-run` (D2), and list it in
`.PHONY` with the others.

### D15 — README covers the decision table, the new commands and the two gotchas

Four sections:

- **Commands** — `link`, `check`, `add`, `restore`, `test`. Adds `check`.
- **Decision table** — all eight cases from D4 as what `link` does per file. This is what
  the current four bullets don't answer, and it's what you want to read before pointing
  this at a home directory: what happens when a real file is already at the target.
- **`fzf` is required** for `restore` (D10).
- **Restore doesn't stick** — the next `link` re-applies the repo's version unless the file
  is removed from `src/`, and `make check` shows it pending (D12).

### D16 — Test coverage

Twelve new scenarios, in the shape of the existing ten: one file per scenario, a `test_body`
taking `tmp_dir` as `$1`, ending with `in_temp_dir test_body`.

**link**

1. `src` and `dest` are the same file — refused, file survives (D9)
2. Directory at the target — `skipped`, directory untouched, no backup (D1)
3. `.DS_Store` in `src/` — `ignored`, not linked (D1)
4. Broken symlink at the target — `repaired` (D6)
5. `--dry-run` changes nothing on disk (D2)

**add**

6. Directory — refused (D9)
7. Already tracked — exit 0, nothing changes (D8)
8. `src/` has it but `$HOME` has a regular file — exit 1 (D8)

**restore**

9. Empty selection — exits without touching anything (D10)
10. No backups at all — exits with a message (D10)
11. Destination missing — restores it anyway (D11)
12. Nested path with missing parents — restores it anyway (D11)

1, 6 and 9 are the safety ones: 1 and 6 are the two halves of the verified data-loss path,
9 is the root-filesystem walk. No test for D3's backup-path message — asserting on output
text is brittle for little return.
