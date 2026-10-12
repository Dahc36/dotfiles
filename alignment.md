# Alignment

Facts are verified against the code. Decisions are recorded once agreed, and describe what
we're going to do.

## Facts

- **Nine words in `link`**, printed by `report` with `printf '%-9s %s\n'`: `ok`, `linked`,
  `replaced`, `backed-up`, `relinked`, `repaired`, `skipped`, `ignored`, `refused`.
  `backed-up` is the longest at nine, which set the column width.
- **One word in `restore`**: `restored`, same `printf`.
- **The README table** is the only documentation of the words, three columns: outcome,
  found at the target, what `link` does.
- **No test asserts on a word.** The restore tests use "restored" only in `test_case`
  descriptions. Renaming touches `link.bash`, `restore.bash` and the README only.
- **The working tree holds the uncommitted `fzpath` work** for `add`. `/align-build`
  needs it committed first.

## Decisions

### D1 — Every word completes "your config at this path was ___"

The subject is the user's file, the tense is past, and the mechanics (symlinks, moves,
removals) stay out of the words. `restored` already fits this sentence.

### D2 — The nine words

| case                          | was         | becomes      |
| ----------------------------- | ----------- | ------------ |
| already a symlink to `src/`   | `ok`        | `unchanged`  |
| nothing at the target         | `linked`    | `added`      |
| file with identical contents  | `replaced`  | `adopted`    |
| file with different contents  | `backed-up` | `replaced`   |
| symlink pointing elsewhere    | `relinked`  | `redirected` |
| broken symlink                | `repaired`  | `repaired`   |
| a directory                   | `skipped`   | `skipped`    |
| `.DS_Store` in `src/`         | `ignored`   | `ignored`    |
| the `src/` file itself        | `refused`   | `refused`    |

`replaced` moves from the identical case to the different one, where the user's version
really was replaced and the README row says the old one is in `backup/`. `restored` stays.

### D3 — `link`'s column widens to ten, `restore` stays at nine

`redirected` is ten characters. The width is local to each script's own longest word; the
two commands never print together, so they needn't match. `restore.bash` is untouched.

### D4 — README: same three columns, new words, `backed-up` reference updated

The table keeps outcome, found at the target, what `link` does. Rows are reworded for the
new words; `replaced` and `redirected` say the old one goes to `backup/`. The gotcha that
names `backed-up` as the pending re-link says `replaced` instead. Nothing else in the
README changes.
