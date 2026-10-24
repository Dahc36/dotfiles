#!/usr/bin/env bash

set -euo pipefail

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
queue_limit=200
numbers=$(gh search prs --review-requested=@me --state=open --draft=false --repo "$repo" --sort created --order asc --limit "$queue_limit" --json number --jq '.[].number')

# --review-requested=@me also matches requests to teams I belong to
me=$(gh api user --jq .login)
for number in $numbers; do
  gh pr view "$number" --json headRefName,reviewRequests --jq "select(any(.reviewRequests[]; .login == \"$me\")) | .headRefName"
done
