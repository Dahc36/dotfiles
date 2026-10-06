#!/usr/bin/env bash

set -euo pipefail

test_suites=(
  "add"
  "link"
  "restore"
)

failed_tests=()

for test_suite in "${test_suites[@]}"; do
  echo "$test_suite"
  for test in "tests/$test_suite"/*.bash; do
    name=${test##*/}
    echo "  • ${name%.bash}"
    bash "$test" || failed_tests+=("$test_suite/${name%.bash}")
  done
done

if (( ${#failed_tests[@]} > 0 )); then
  printf '\nFAILED — %d scenario(s):\n' "${#failed_tests[@]}"
  printf '  %s\n' "${failed_tests[@]}"
  exit 1
fi

echo "PASSED"
