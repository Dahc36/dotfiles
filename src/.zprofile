eval "$(/opt/homebrew/bin/brew shellenv)"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# PosgreSQL
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Lua
export PATH="$HOME/.luarocks/bin:$PATH"

# Claude
export PATH="$HOME/.local/bin:$PATH"