# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **Nothing exists yet.** No `~/bin`, no `~/.zshenv`. `~/.zshrc:2` carries oh-my-zsh's
  commented-out template line mentioning `$HOME/bin`. `~/.local/bin` is on `PATH` through
  `src/.zprofile:15`, which is slated for rework.
- **Shells:** bash 3.2.57 for scripts, zsh 5.9 interactive. `fzf` 0.74.4 with `--header`,
  `--prompt`, `--cycle`.
- **BSD `ls -Ap`** lists dotfiles, marks real directories with a trailing `/`, and lists a
  symlink to a directory *without* one. `ls -ApL` follows symlinks and marks it. An empty
  directory lists nothing.
- **`add` today** reads one path relative to `$HOME` from a `read` prompt, then runs its
  guards. The six `tests/add/*.bash` feed that prompt through stdin. The restore tests stub
  `fzf` with a script on a prepended `PATH`.
- **Repo rule on exec bits:** `scripts/*.bash` are `644` because `make` is their entry
  point. A script whose entry point is `PATH` needs `755`; git tracks the bit and a symlink
  resolves to its target's mode, so `make link` preserves it.
- **The repo is WIP.** `src/` is being pruned; the script and its wiring are created in
  `$HOME` first and tracked later.

## Decisions

### D1 — A new `~/.zshenv` holds the `PATH` line, and nothing else

`export PATH="$HOME/bin:$PATH"`, with a one-line comment saying it's for the scripts in
`~/bin`. Per `man zsh` STARTUP/SHUTDOWN FILES, `.zshenv` is read on every zsh invocation
and is the file meant for the command search path. Login and interactive shells, tmux
panes (which start login shells, per the empty `default-command` default) and `zsh -c` all
get it; `make` and `bash` inherit it as exported environment. Processes with no zsh
ancestor, such as cron or Dock-launched apps, don't, and that's accepted.

macOS's `path_helper` reorders `PATH` in login shells, moving `~/bin` after the system
directories. Harmless here: nothing in `~/bin` shadows a system command.

Created directly in `$HOME`; tracked in `src/` later, when `src/` is pruned.

### D2 — The command is `fzpath`

`~/bin/fzpath`. The `fz` prefix follows the `fzf` ecosystem's naming and avoids collisions;
`path` says what comes out. Free on `PATH` and in zsh.

### D3 — Written in bash 3.2, like the repo's scripts

`#!/usr/bin/env bash`, `set -euo pipefail`, no features past 3.2. Executable (`755`),
since `PATH` is its entry point.

### D4 — Starts at the directory given as `$1`, default the current one

`fzpath` alone navigates from where you are; `add.bash` calls `fzpath "$HOME"`. A start
that isn't a directory is an error, exit 1.

### D5 — The output is usable from the caller's directory, in the caller's form

Internally the navigator tracks a path relative to the start. On output, if `$1` was given
it is prefixed as given, trailing slash dropped: `fzpath src` → `src/link.bash`,
`fzpath "$HOME"` → `/Users/hans/.config/nvim/init.lua`, `fzpath ..` → `../x`. With no
argument the relative path is printed as is, no `./`. The caller decides relative versus
absolute by what it passes; `add.bash` passes `$HOME` and strips `$HOME/` once.

### D6 — Each level is `ls -AF`: dotfiles shown, every entry visibly typed

`/` marks a directory, `@` a symlink, `*` an executable, as BSD `ls -F` prints them. The
marker is stripped from the selection before use. A `/` entry is entered. Everything else,
`@` included, is a leaf: Enter selects it and prints its path. Symlinks are never followed,
so a symlinked directory can be selected but not entered, and a link cycle can't be walked.

### D7 — `..` at every level, including above the start

The script adds `..` as the first entry at every level. The tracked relative path stays
normalized: picking `..` drops the last real segment if there is one (`a/b` → `a`, `a` →
empty), otherwise appends `..` (empty → `..`, `..` → `../..`). So `..` only ever appears at
the front of the path, and the output can be `../other/file` or `src/../x` in the caller's
form.

`add.bash` refuses a path that is `..` or starts with `../` after stripping `$HOME/`, with
a message that only files under `$HOME` can be tracked. That guard is sufficient because
`fzpath`'s output is normalized; a hand-typed argument isn't hardened further.

### D8 — `fzf --header` shows the current directory

In the caller's form (D5), with a trailing slash: `src/`, `src/link/`, `../`. At the start
with no argument the header is `./`.

### D9 — A `.` entry selects the current directory

Listed first, before `..`. Picking it prints the current directory's path in the caller's
form: `.` at the start with no argument, `src/link` after two hops from `src`. That makes
`cd "$(fzpath)"` work without a flag or a second mode.

### D10 — Failure paths follow `restore`

`command -v fzf` up front, exit 1 with a message naming it. Escape propagates `fzf`'s exit
status: nothing printed, non-zero exit. An empty directory lists just `.` and `..`.

### D11 — `add` takes an optional path argument, and runs `fzpath "$HOME"` without one

The `read` prompt goes away. With no argument: `command -v fzpath` first, exit 1 with a
message naming it if missing; then `prompt=$(fzpath "$HOME") || exit 1`, strip `$HOME/`,
refuse an empty result and `..` paths (D7), then the existing guards unchanged. With an
argument, `fzpath` is never checked or run. Output lines and messages stay as they are.

### D12 — Tests: the six `add` scenarios pass the argument, three new ones stub `fzpath`

Existing `tests/add/*.bash` replace `echo "<path>" |` with the path as the argument and
keep their assertions. Three new scenarios, each with a stub `fzpath` on a prepended `PATH`:

1. **Selection** — the stub prints `$tmp_dir/home/.example`; asserts the file is tracked
   and the home path links to `src/`.
2. **Cancel** — the stub exits 130; asserts a non-zero exit and nothing moved.
3. **Outside home** — the stub prints `$tmp_dir/home/../outside`; asserts exit 1 and
   nothing moved.

`fzpath` itself gets tests when it's tracked in the repo, not before.

### D13 — README: the `make add` bullet only

It says `add` picks a `$HOME` file with `fzpath`. No Setup step: `fzpath` and `.zshenv`
get tracked with `make add` right after this work, and `make link` provides them from then
on.

### D14 — The first build run writes the two `$HOME` files, then makes the repo commit

`~/bin/fzpath` (755) and `~/.zshenv` are created directly in `$HOME`, per D1 to D10, in
the same run that changes `add.bash`, the tests and the README. The summary names both
files so they can be reviewed alongside the diff. They're tracked with `make add`
afterwards, by hand.
