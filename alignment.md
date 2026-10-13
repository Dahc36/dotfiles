# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **The want:** copy one line of what's on the terminal to the clipboard, picked with `fzf`,
  instead of selecting it by hand in tmux's vi copy mode.
- **tmux 3.7c**, prefix `C-b`. `src/.tmux.conf` sets `mode-keys vi` and remaps `"`, `%` and
  `c` to open in the current pane's path; nothing else. No plugins are installed.
- **`display-popup -E "<command>"`** draws a popup over the panes, runs the command in it,
  and closes when it exits. Default size is half the terminal; `-w`/`-h` take percentages.
  Inside the popup, `#{…}` formats are *not* expanded and `TMUX_PANE` is unset, but a bare
  `tmux capture-pane -p` targets the pane under the popup, and the working directory is that
  pane's. (`run-shell` does expand formats, but gives the command no terminal.)
- **`tmux capture-pane -p -J -S -`** prints the pane's whole scrollback, oldest line first,
  wrapped lines rejoined by `-J`. Blank lines come through as empty lines.
- **Prefix keys:** `f` is tmux's default `find-window`. `y` is bound in no key table at all,
  prefix, root or copy-mode-vi included.
- **Clipboard:** `/usr/bin/pbcopy`; not yet exercised from inside a popup.
- **fzf 0.74:** `--tac` shows the last input line first, `--no-sort` keeps that order under
  a query, `--multi` allows several picks.
- **Off-the-shelf alternative:** the `extrakto` tmux plugin captures the pane into `fzf` and
  copies or inserts the pick, plus word/path/URL extraction; it needs a plugin install.
- **Checks available:** `tmux -f src/.tmux.conf -L <name> new-session -d` parses the config
  on a throwaway server, whose `list-keys` then shows the binding. `tests/run.bash` covers
  the bash scripts only.

## Decisions

### D1 — A `bind` in `src/.tmux.conf` that opens `fzf` in a `display-popup`

No plugin. The binding pipes `capture-pane` into `fzf` inside the popup and the pick into
`pbcopy`. Lives next to the three existing remaps.

### D2 — The key is `prefix y`

Yank, matching `mode-keys vi`. No default is shadowed.

### D3 — The list is the whole scrollback, most recent line first, blanks dropped

`tmux capture-pane -p -J -S -`, blank lines filtered out, into `fzf --tac --no-sort`, so
the visible screen is the top of the list and older lines follow.

### D4 — One line per pick

No `--multi`. Escape closes the popup and leaves the clipboard untouched.

### D5 — The pick goes to the clipboard, nothing else

The pipeline ends in `pbcopy`. No paste-into-pane action.

### D6 — The copy is trimmed at both ends; the list shows lines as captured

Leading indentation stays visible in `fzf` to help find the line; only what reaches
`pbcopy` has leading and trailing whitespace stripped.

### D7 — The popup is full width and full height, with tmux's border

`-w 100% -h 100%`, no `-B`, no title. The border may be dropped after trying it.

### D8 — Verification is the config parse; the popup and clipboard are tried by hand

The build loads `src/.tmux.conf` into a throwaway tmux server and confirms `prefix y` is
bound as written. No clipboard writes, no automated popup. After `make link` and
`tmux source-file ~/.tmux.conf`, the binding is tried live.
