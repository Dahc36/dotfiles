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

# fzgcode: pick changed files with fzf (tab marks several) and open them in VS Code
fzgcode() {
  local root
  root=$(git rev-parse --show-toplevel) || return

  local yellow=$'\e[33m' green=$'\e[32m' reset=$'\e[m'
  # from the root, as ls-files only lists under the cwd; quotePath off keeps
  # non-ASCII names as they are instead of octal escapes
  local changed=$({
    git -C "$root" -c core.quotePath=false diff --name-only --diff-filter=d HEAD |
      sed "s/.*/$yellow&$reset/"
    git -C "$root" -c core.quotePath=false ls-files --others --exclude-standard |
      sed "s/.*/$green&$reset/"
  })
  if [[ -z $changed ]]; then
    echo "Nothing changed" >&2
    return 1
  fi

  local files
  files=$(fzf --layout=reverse --multi --ansi <<< "$changed") || return

  local file paths=()
  for file in ${(f)files}; do
    paths+=("$root/$file")
  done
  code "${paths[@]}"
}
