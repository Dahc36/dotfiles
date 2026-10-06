# DotFiles

All .dotfiles you want to keep track of.
Each one should be defined in the `src/` folder, mirroring their path within `$HOME`.

## Setup

1. Install [Homebrew](https://brew.sh/)
   1. or update: `brew upgrade`
2. Install [fzf](https://github.com/junegunn/fzf)
3. Install [ripgrep](https://github.com/burntsushi/ripgrep)

## Commands

- `pull` syncs `src/` with your local files
- `push` syncs your local files with src
- `add` copies a local file into src
- `chmod` makes all scripts executable
