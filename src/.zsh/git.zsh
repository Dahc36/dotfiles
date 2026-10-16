# _fzg_branches: print one line per local branch, current branch first, sorted
# by commit date: name, its PR state on GitHub (colored) and its last commit date
_fzg_branches() {
  local current
  current=$(git rev-parse --abbrev-ref HEAD) || return

  local branches=() dates=() line
  for line in ${(f)"$(git branch --sort=committerdate --format='%(refname:lstrip=2)%09%(committerdate:relative)')"}; do
    branches+=("${line%%$'\t'*}")
    dates+=("${line#*$'\t'}")
  done

  local -A merged
  local default
  if default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
    for line in ${(f)"$(git branch --merged "$default" --format='%(refname:lstrip=2)')"}; do
      merged[$line]=1
    done
  fi

  # PRs are looked up by head branch name: GitHub deletes the remote branch once merged
  local query='query($owner:String!,$name:String!' fields='' args=() i
  for i in {1..$#branches}; do
    query+=",\$b$i:String!"
    fields+="b$i:pullRequests(headRefName:\$b$i,first:1,orderBy:{field:UPDATED_AT,direction:DESC}){nodes{number state isDraft}} "
    args+=(-f "b$i=${branches[$i]}")
  done
  query+="){repository(owner:\$owner,name:\$name){$fields}}"
  # one line per branch with a PR: branch index, PR number, state (DRAFT when open as a draft)
  local jq='.data.repository | to_entries[] | select(.value.nodes[0]) | .value.nodes[0] as $pr
    | "\(.key | ltrimstr("b")) \($pr.number) \(if $pr.isDraft then "DRAFT" else $pr.state end)"'

  local red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' reset=$'\e[m'
  local statuses=() colors=() prs number state
  if prs=$(gh api graphql -F owner='{owner}' -F name='{repo}' "${args[@]}" -f query="$query" --jq "$jq" 2>/dev/null); then
    for i in {1..$#branches}; do
      statuses[$i]="no PR"
      if [[ -n ${merged[${branches[$i]}]} ]]; then
        statuses[$i]="no PR, merged"
        colors[$i]=$green
      fi
    done
    for line in ${(f)prs}; do
      read -r i number state <<< "$line"
      case $state in
        MERGED) statuses[$i]="merged #$number"; colors[$i]=$green ;;
        CLOSED) statuses[$i]="abandoned #$number"; colors[$i]=$red ;;
        DRAFT) statuses[$i]="draft #$number"; colors[$i]=$yellow ;;
        OPEN) statuses[$i]="pending #$number"; colors[$i]=$yellow ;;
      esac
    done
  else
    echo "_fzg_branches: could not fetch PR state" >&2
  fi

  local -i name_width=0 status_width=0
  for i in {1..$#branches}; do
    (( ${#branches[$i]} > name_width )) && name_width=${#branches[$i]}
    (( ${#statuses[$i]} > status_width )) && status_width=${#statuses[$i]}
  done

  local header=$current rows=() row
  for i in {1..$#branches}; do
    printf -v row '%-*s  %s%-*s%s  %s' \
      $name_width "${branches[$i]}" \
      "${colors[$i]}" $status_width "${statuses[$i]}" "${colors[$i]:+$reset}" \
      "${dates[$i]}"
    if [[ ${branches[$i]} == $current ]]; then
      header=$row
    else
      rows+=("$row")
    fi
  done
  printf '%s\n' "$header" "${rows[@]}"
}

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

# fzgprune: pick local branches with fzf (tab marks several) and delete them;
# each line shows the branch's PR state on GitHub and its last commit date
fzgprune() {
  local rows
  rows=$(_fzg_branches) || return

  local picked
  picked=$(fzf --layout=reverse --header-lines=1 --multi --ansi <<< "$rows") || return

  local line
  for line in ${(f)picked}; do
    git branch -D "${line%% *}"
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
