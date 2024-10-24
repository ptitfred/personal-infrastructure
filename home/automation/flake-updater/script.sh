set -e

# shellcheck disable=SC2154
GITHUB_TOKEN=$(cat "$githubTokenFile")
export GITHUB_TOKEN

NIX_CONFIG="extra-access-tokens = github.com=${GITHUB_TOKEN}"
export NIX_CONFIG

if [ -n "$baseBranch" ]
then
  baseBranch="main"
fi

if [ -n "$prBranch" ]
then
  prBranch="automated-inputs-update"
fi

dir=$(mktemp -d)
commit_message=$(mktemp)
flake_update_logs=$(mktemp)

nix --version

# shellcheck disable=SC2154
git clone "$localWorkingCopy" "$dir"
pushd "$dir"

function cleanup {
  popd
  rm -rf "$dir" "$commit_message" "$flake_update_logs"
  exit "$1"
}

# shellcheck disable=SC2154
git remote add github "$gitRemoteUrl"
git fetch github

git branch "$prBranch" "github/${baseBranch}"
git checkout "$prBranch"

nix flake update 2>> "$flake_update_logs"

title="Automated flake inputs updated"

{
  echo "$title"
  echo ""
  echo "Changes:"
  echo ""
  echo "\`\`\`"
  tail -3 <"$flake_update_logs" | head -1 | sed 's/@nix//' | jq .msg -r | grep -v "warning"
  echo "\`\`\`"
} > "$commit_message"

git add -u flake.lock
git commit -F "$commit_message" -- flake.lock || cleanup 0

other_diffs=$(git status -s | wc -l)
if [ "$other_diffs" == "0" ]; then
  # shellcheck disable=SC2154
  $checkCommand

  git push --force-with-lease github HEAD
  gh pr create --base "${baseBranch}" --head "$prBranch" --title "$title" --body "$commit_message" || echo "PR already present."
  cleanup 0
else
  echo "Other diffs detected, can't update blindly:"
  git status -s
  cleanup 1
fi
