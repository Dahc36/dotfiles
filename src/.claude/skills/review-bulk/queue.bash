#!/usr/bin/env bash

set -euo pipefail

export GH_PAGER=cat GH_PROMPT_DISABLED=1 GH_SPINNER_DISABLED=1 GH_NO_UPDATE_NOTIFIER=1

# review-requested:@me also matches requests to teams I belong to
me=$(gh api user --jq .login)
queue_limit=200
gh pr list \
  --search "review-requested:@me draft:false sort:created-asc" \
  --state open \
  --limit "$queue_limit" \
  --json headRefName,reviewRequests \
  --jq ".[] | select(any(.reviewRequests[]; .login == \"$me\")) | .headRefName"
