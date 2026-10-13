# fzgco [git branch flags]: pick a branch with fzf and check it out; -a includes remote branches
fzgco() {
  local current
  current=$(git rev-parse --abbrev-ref HEAD) || return

  local branch
  branch=$({
    echo "$current"
    git branch "$@" --format='%(refname:lstrip=2)' | grep -vxF "$current" | grep -v '/HEAD$'
  } | fzf --layout=reverse --header-lines=1) || return

  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    # a remote branch: without the remote name, git creates a local tracking branch
    branch="${branch#*/}"
  fi
  git checkout "$branch"
}
