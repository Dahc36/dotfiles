source tests/utils.bash

principles=(src/.claude/skills/principles/*.md)
skills=(src/.claude/skills/*/SKILL.md)

tags_named_by_skills() {
  grep -ho '`aiprinciples [a-z ]*`' "${skills[@]}" | tr -d '`' | cut -d' ' -f2- | tr ' ' '\n' | sort -u
}

tags_carried_by_principles() {
  grep -h '^tags: \[' "${principles[@]}" | sed 's/^tags: \[//; s/\]$//' | tr -s ', ' '\n' | sort -u
}

every_principle_has_a_tag() {
  local file
  for file in "${principles[@]}"; do
    grep -q '^tags: \[[a-z][a-z, -]*\]$' "$file" || return 1
  done
}

test_case "Every principle carries at least one tag" every_principle_has_a_tag
test_case "Every tag a skill names exists in some principle" \
  test -z "$(comm -23 <(tags_named_by_skills) <(tags_carried_by_principles))"
test_case "Every tag a principle carries is named by some skill" \
  test -z "$(comm -13 <(tags_named_by_skills) <(tags_carried_by_principles))"
test_case "No skill points at the principles folder by path" \
  test -z "$(grep -l 'skills/principles' "${skills[@]}")"
