eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# user-level installs: uv tool, pipx, claude, anything following the XDG convention
export PATH="$HOME/.local/bin:$PATH"

# scripts of my own live in ~/bin
export PATH="$HOME/bin:$PATH"

# React Native, only where the Android SDK is installed
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi
