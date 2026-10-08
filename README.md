# dotfiles

All .dotfiles you want to keep track of.
Each one should be defined in the `src/` folder, mirroring their path within `$HOME`.

## Setup

1. Install [Homebrew](https://brew.sh/)
   1. or update: `brew upgrade`
2. Install [fzf](https://github.com/junegunn/fzf)
3. Install [ripgrep](https://github.com/burntsushi/ripgrep)

## Commands

Run them from the repo root; the scripts refuse to run from anywhere else.

- `make link` syncs `src/` with your local files, by adding symlinks to your `$HOME`
- `make check` reports what `make link` would do, without touching anything
- `make add` moves a `$HOME` file into `src/`, leaving behind a symlink pointing to the moved file
- `make restore` puts a backup's files back into `$HOME`, choosing one with `fzf`
- `make test` runs a test suite against the existing scripts
