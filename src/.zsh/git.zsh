# _fzg_branches: one tab-separated line per local branch, current branch first,
# then by commit date: name, last commit date, and `merged` when the default
# branch already contains it (empty otherwise)
_fzg_branches() {
  local listed
  listed=$(git branch --sort=committerdate --sort=-HEAD --format='%(refname:lstrip=2)%09%(committerdate:relative)') || return
  [[ -n $listed ]] || return 1

  local -A merged
  local default line
  if default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD); then
    for line in ${(f)"$(git branch --merged "$default" --format='%(refname:lstrip=2)')"}; do
      merged[$line]=1
    done
  fi

  for line in ${(f)listed}; do
    printf '%s\t%s\n' "$line" "${merged[${line%%$'\t'*}]:+merged}"
  done
}

# _fzg_pr_states: fill the status of each line read from stdin with the branch's
# PR state on GitHub; when the fetch fails every status becomes `?` and the
# return is non-zero
_fzg_pr_states() {
  local lines=(${(f)"$(cat)"})

  # PRs are looked up by head branch name: GitHub deletes the remote branch once merged
  local query='query($owner:String!,$name:String!' fields='' args=() i
  for i in {1..$#lines}; do
    query+=",\$b$i:String!"
    fields+="b$i:pullRequests(headRefName:\$b$i,first:1,orderBy:{field:UPDATED_AT,direction:DESC}){nodes{number state isDraft}} "
    args+=(-f "b$i=${lines[$i]%%$'\t'*}")
  done
  query+="){repository(owner:\$owner,name:\$name){$fields}}"
  # one line per branch with a PR: branch index, PR number, state (DRAFT when open as a draft)
  local jq='.data.repository | to_entries[] | select(.value.nodes[0]) | .value.nodes[0] as $pr
    | "\(.key | ltrimstr("b")) \($pr.number) \(if $pr.isDraft then "DRAFT" else $pr.state end)"'

  local prs
  if ! prs=$(gh api graphql -F owner='{owner}' -F name='{repo}' "${args[@]}" -f query="$query" --jq "$jq" 2>/dev/null); then
    for i in {1..$#lines}; do
      printf '%s\t?\n' "${lines[$i]%$'\t'*}"
    done
    return 1
  fi

  local statuses=()
  for i in {1..$#lines}; do
    statuses[$i]="no PR"
    [[ ${lines[$i]##*$'\t'} == merged ]] && statuses[$i]="no PR, merged"
  done
  local line number state
  for line in ${(f)prs}; do
    read -r i number state <<< "$line"
    case $state in
      MERGED) statuses[$i]="merged #$number" ;;
      CLOSED) statuses[$i]="closed #$number" ;;
      DRAFT) statuses[$i]="draft #$number" ;;
      OPEN) statuses[$i]="open #$number" ;;
    esac
  done
  for i in {1..$#lines}; do
    printf '%s\t%s\n' "${lines[$i]%$'\t'*}" "${statuses[$i]}"
  done
}

# _fzg_rows: turn the tab-separated lines read from stdin into aligned fzf rows,
# coloring the status: merged green, closed red, draft and open yellow, and a
# dim `…` where it is still empty
_fzg_rows() {
  local names=() dates=() statuses=() line
  for line in ${(f)"$(cat)"}; do
    names+=("${line%%$'\t'*}")
    dates+=("${${line#*$'\t'}%%$'\t'*}")
    statuses+=("${${line##*$'\t'}:-…}")
  done

  local -i name_width=0 date_width=0 i
  for i in {1..$#names}; do
    (( ${#names[$i]} > name_width )) && name_width=${#names[$i]}
    (( ${#dates[$i]} > date_width )) && date_width=${#dates[$i]}
  done

  local red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' dim=$'\e[2m' reset=$'\e[m' color
  for i in {1..$#names}; do
    case ${statuses[$i]} in
      *merged*) color=$green ;;
      closed*) color=$red ;;
      draft*|open*) color=$yellow ;;
      …) color=$dim ;;
      *) color='' ;;
    esac
    printf '%-*s  %-*s  %s%s%s\n' \
      $name_width "${names[$i]}" \
      $date_width "${dates[$i]}" \
      "$color" "${statuses[$i]}" "${color:+$reset}"
  done
}

# fzgco: pick a local branch with fzf and check it out; the list shows at once
# and the PR states fill in when GitHub answers
fzgco() {
  local lines
  lines=$(_fzg_branches) || return

  local fifo
  fifo=$(mktemp -u) && mkfifo "$fifo" || return
  # without job control the shell stays quiet about the job
  setopt localoptions nomonitor
  ( setopt pipefail; _fzg_pr_states <<< "$lines" | _fzg_rows > "$fifo" ) &
  local job=$!

  # once fzf has shown the fast list it swaps in the fifo's content
  local picked fzf_status
  picked=$(_fzg_rows <<< "$lines" | fzf --layout=reverse --header-lines=1 --ansi \
    --bind "load:unbind(load)+reload-sync(cat '$fifo')")
  fzf_status=$?

  if kill -0 $job 2>/dev/null; then
    # a fetch still running dies on its own once it writes to the dead pipe
    kill $job
  elif ! wait $job; then
    echo "fzgco: could not fetch PR state" >&2
  fi
  rm "$fifo"
  (( fzf_status == 0 )) || return $fzf_status

  git checkout "${picked%% *}"
}

# fzgprune: pick local branches with fzf (tab marks several) and delete them;
fzgprune() {
  local lines
  lines=$(_fzg_branches) || return
  lines=$(_fzg_pr_states <<< "$lines") || echo "fzgprune: could not fetch PR state" >&2

  local picked
  picked=$(_fzg_rows <<< "$lines" | fzf --layout=reverse --header-lines=1 --multi --ansi) || return

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
