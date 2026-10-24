#!/usr/bin/env bash
# Usage: setup-repo.sh <repo> [required-check]...
#
# Applies the organization's repository defaults to wloophq/<repo>: squash
# merge only, with the pull request's title and body; head branches deleted on
# merge; wiki off; and a ruleset on the default branch that requires a pull
# request, linear history and the given status checks, and blocks force pushes
# and deletion, with repository admins able to bypass. Security features come
# from the organization's default code security configuration.
set -euo pipefail

repo=${1:?usage: setup-repo.sh <repo> [required-check]...}
shift
full=wloophq/$repo

gh api -X PATCH "repos/$full" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -F delete_branch_on_merge=true -F allow_update_branch=true -F allow_auto_merge=true \
  -F has_wiki=false --jq '{allow_squash_merge, allow_merge_commit, allow_rebase_merge, delete_branch_on_merge}'

checks=$(printf '%s\n' "$@" | jq -R 'select(length > 0) | {context: ., integration_id: 15368}' | jq -s .)

rules='[
  {"type": "deletion"},
  {"type": "non_fast_forward"},
  {"type": "required_linear_history"},
  {"type": "pull_request", "parameters": {"required_approving_review_count": 0, "dismiss_stale_reviews_on_push": true, "require_code_owner_review": false, "require_last_push_approval": false, "required_review_thread_resolution": true, "allowed_merge_methods": ["squash"]}}
]'
if [[ $(jq length <<<"$checks") -gt 0 ]]; then
  rules=$(jq --argjson c "$checks" '. + [{"type": "required_status_checks", "parameters": {"strict_required_status_checks_policy": false, "required_status_checks": $c}}]' <<<"$rules")
fi

existing=$(gh api "repos/$full/rulesets" --jq '.[] | select(.name == "main") | .id')
body=$(jq -n --argjson rules "$rules" '{
  name: "main", target: "branch", enforcement: "active",
  conditions: {ref_name: {include: ["~DEFAULT_BRANCH"], exclude: []}},
  bypass_actors: [{actor_id: 5, actor_type: "RepositoryRole", bypass_mode: "always"}],
  rules: $rules
}')
if [[ -n $existing ]]; then
  gh api -X PUT "repos/$full/rulesets/$existing" --input - --jq '{id, name, enforcement}' <<<"$body"
else
  gh api -X POST "repos/$full/rulesets" --input - --jq '{id, name, enforcement}' <<<"$body"
fi
