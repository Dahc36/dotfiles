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

# fzgprune: pick local branches with fzf (tab marks several) and delete them; unmerged ones ask before -D
fzgprune() {
  local current
  current=$(git rev-parse --abbrev-ref HEAD) || return

  local branches
  branches=$({
    echo "$current"
    git branch --format='%(refname:lstrip=2)' | grep -vxF "$current"
  } | fzf --layout=reverse --header-lines=1 --multi) || return

  local branch answer
  for branch in ${(f)branches}; do
    git branch -d "$branch" && continue
    read "answer?Force delete $branch? [y/N] "
    if [[ $answer == y ]]; then
      git branch -D "$branch"
    fi
  done
}
