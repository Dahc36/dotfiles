# dotfiles

Dotfiles to keep track of, in `src/`, mirroring their path in `$HOME`.

## Setup

1. Install [Homebrew](https://brew.sh/)
   1. NOTE: if already installed, run `brew upgrade` instead
2. Install [fzf](https://github.com/junegunn/fzf)
3. Install [ripgrep](https://github.com/burntsushi/ripgrep)
4. Run `make check` and read what it would do
5. Run `make link`

## Commands

From the repo root:

- `make link` symlinks every file in `src/` into `$HOME`
- `make check` shows what `make link` would do, touching nothing
- `make add` moves a `$HOME` file into `src/` and symlinks it back
- `make restore` puts a backup's files back into `$HOME`, picked with `fzf`
- `make test` runs the test suite

## What `link` does with each file

One line per file: an outcome and the `$HOME` path.

| outcome     | found at the target            | what `link` does                 |
| ----------- | ------------------------------ | -------------------------------- |
| `ok`        | a symlink to `src/`            | nothing                          |
| `linked`    | nothing                        | creates the symlink              |
| `replaced`  | a file with identical contents | removes it, creates the symlink  |
| `backed-up` | a file with different contents | backs it up, creates the symlink |
| `relinked`  | a symlink pointing elsewhere   | backs it up, creates the symlink |
| `repaired`  | a broken symlink               | backs it up, creates the symlink |
| `skipped`   | a directory                    | nothing                          |
| `ignored`   | a `.DS_Store` in `src/`        | nothing                          |
| `refused`   | the `src/` file itself         | nothing                          |

Backups go to `backup/<timestamp>/`, printed at the end of the run.

Two outcomes need you:

1. `skipped`: move the directory out of the way, then run `make link` again
2. `refused`: remove the tracked directory from `src/`, then run `make link` again
   1. NOTE: it means a directory got tracked, and its files now resolve to themselves

## Gotchas

`restore` leaves `src/` alone, so the next `make link` backs the restored file up again
and re-links the repo's version. To keep it:

1. Remove it from `src/`
2. Run `make check` and confirm it no longer shows as `backed-up`
