# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **The habit to replace:** `print -z $(history -n 1 | fzf)`. `print -z` pushes its arguments
  onto the editing buffer, so the picked command appears at the prompt, ready to edit or run.
- **`history` under oh-my-zsh is `omz_history`**, a wrapper that runs `builtin fc -l` with the
  given arguments; `history -n 1` is `fc -ln 1`: every event, oldest first, no numbers.
  A multi-line entry prints on one line with literal `\n` between its lines, so picking one
  would push that text, not the real newlines.
- **oh-my-zsh's history options:** `hist_ignore_dups` only drops consecutive repeats, so the
  list has duplicates; `share_history` merges sessions; `HISTSIZE` is 50000.
- **Unquoted `$(…)` collapses runs of spaces** when `print -z` joins the words back;
  `print -z "$(…)"` keeps the command as typed. Neither globs (`GLOB_SUBST` is off).
- **fzf ships its own history widget:** `source <(fzf --zsh)` binds `ctrl-r` to
  `fzf-history-widget`, which lists most recent first, deduplicates, handles multi-line
  entries, seeds the query with what's already typed, and puts the pick in the buffer.
  It also binds `ctrl-t` (file picker) and `alt-c` (cd). Nothing in `.zshrc` sources it.
- **Where helpers live:** `src/.zsh/git.zsh` holds `fzgco` and `fzgprune`, sourced from
  `.zshrc` under "shell functions of my own live in ~/.zsh". Both run `fzf --layout=reverse`.
- **Tests:** none cover zsh; the previous helpers were verified by hand with `fzf` stubbed.

## Decisions

### D1 — Use fzf's own shell integration instead of a helper of our own

`.zshrc` sources `fzf --zsh`. No new function in `src/.zsh/`.

### D2 — Source it as is: `ctrl-r` and `ctrl-t` in use, `alt-c` left bound

Nothing is unbound. The terminal sends Option as `ç` rather than Meta today, so `alt-c`
stays inert until the terminal is set to use Option as Meta; no shell-side workaround.

### D3 — The line goes at the end of `.zshrc`, before the `~/.zsh/git.zsh` block

`.zshrc` keeps the oh-my-zsh template as is, commented examples included. Own additions
stay where they are, at the bottom of the user section. The new block sits between
`mise` and the `~/.zsh/git.zsh` block:

```zsh
# fzf key bindings: ctrl-r history, ctrl-t files, alt-c cd
source <(fzf --zsh)
```
