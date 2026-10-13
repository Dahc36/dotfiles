# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **`fzpath` is tracked** at `src/bin/fzpath`, linked from `~/bin/fzpath`. The working tree
  holds an uncommitted change to it: `--no-clear` plus a `trap 'tput rmcup > /dev/tty' EXIT`.
- **Today's shape:** a bash loop; each level pipes `.`, `..` and `ls -AF "$dir"` into a fresh
  `fzf --header "$(location)/"`, with `path` (relative to the start, normalized so `..` is
  only ever at the front), `go_up`, `location`, and a `case` on the picked entry: `.` prints
  the location, `..` goes up, `*/` descends, anything else strips the `ls -F` marker and
  prints `$prefix${path:+$path/}$name`. `prefix` is `$1/` as given, or empty.
- **`fzf` 0.74 bindings:** `reload(cmd)` replaces the list with `cmd`'s output;
  `transform(cmd)` runs `cmd` and executes the actions it prints, e.g.
  `reload(...)+change-prompt(...)`; `become(cmd)` replaces the `fzf` process with `cmd`
  (its stdout is `fzf`'s stdout); `change-prompt(str)` and `change-header(str)` set the
  chrome. `{}` in a binding is the current line, single-quoted. Commands run by bindings
  get `FZF_PROMPT`, `FZF_QUERY`, `FZF_POS` and others as environment variables; there is no
  `FZF_HEADER`.
- **The `start` event** fires once when `fzf` opens, so the initial list can be loaded by
  the same `reload` the navigation uses, with no stdin piped in.
- **No tests exist for `fzpath`**; it was decided they'd come once it was tracked, which it
  now is.

## Decisions

### D1 — The current directory lives in the prompt

`--prompt` shows the location as the header does today (`./`, `src/link/`, `../`), and
replaces the header. Every binding reads it back from `FZF_PROMPT`: strip the caller's
prefix, strip the trailing `/`, and `.` means the start. `change-prompt` updates state and
display together. Nothing is written to disk.

### D2 — The bindings call the script back through two hidden subcommands

`fzpath [start]` starts `fzf` with `--bind "start:reload($0 --list)"` and
`--bind "enter:transform($0 --enter {})"`. `fzpath --list` prints `.`, `..` and
`ls -AF` of the current directory; `fzpath --enter <line>` prints the actions `fzf` should
run next. The start directory and the caller's prefix reach the subcommands as exported
variables. The logic stays as plain functions in the one file; a one-line comment marks
the subcommands as `fzf`'s, not the user's.

### D3 — The query is cleared on every navigation

The actions printed for `..` and for a directory end with `+clear-query`, so each level
starts with an empty filter, as the relaunching version did.

### D4 — Tests: a `fzpath` suite exercising the two subcommands

Run as `bash ../src/bin/fzpath --list` and `--enter <line>` from the temp dir, with the
start, prefix and `FZF_PROMPT` variables set by the test. No scenario drives the real
`fzf`. Added to `tests/run.bash`'s suites. Scenarios:

1. **list** — `.`, `..` first, then entries with `ls -AF` markers, for a directory holding
   a file, a subdirectory, a symlink and an executable.
2. **enter directory** — prints `reload(…)+change-prompt(<location>/)+clear-query` with
   the new location.
3. **up at the start** — prompt `./`, line `..` → location `../`.
4. **up below the start** — prompt `src/link/`, line `..` → `src/`.
5. **pick here** — line `.` → `become(echo <location>)`, with the prefix as given.
6. **pick a file** — `script*` → `become(echo <prefix><path>/script)`, marker stripped.

### D5 — Everything else is unchanged, and the `--no-clear` workaround goes

The `fzf` and start-directory checks, the caller's-form output, the `.` and `..` entries,
the `ls -AF` markers and the `..` normalization keep their current behavior. Escape still
ends the run with `fzf`'s status and no output; a pick ends it through `become`, exit 0.
The uncommitted `--no-clear` flag and the `rmcup` trap are dropped: one process owns the
screen, so there is nothing to restore.
