# dotfiles

All .dotfiles you want to keep track of.
Each one should be defined in the `src/` folder, mirroring their path within `$HOME`.

## Setup

1. Install [Homebrew](https://brew.sh/)
   1. or update: `brew upgrade`
2. Install [fzf](https://github.com/junegunn/fzf)
3. Install [ripgrep](https://github.com/burntsushi/ripgrep)

## Commands

- `link` syncs `src/` with your local files, by adding symlinks to your `$HOME`
- `add` moves a `$HOME` file into `src/`, leaving behind a symlink pointing to the moved file
- `chmod` makes all scripts executable
- `test` runs a test suite against the existing scripts
