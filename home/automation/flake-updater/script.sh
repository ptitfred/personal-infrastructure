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
body=$(mktemp)
commit_message=$(mktemp)
flake_update_logs=$(mktemp)

nix --version

# shellcheck disable=SC2154
git clone "$localWorkingCopy" "$dir"
pushd "$dir"

function cleanup {
  popd
  rm -rf "$dir" "$body" "$commit_message" "$flake_update_logs"
  exit "$1"
}

function extract_logs {
  grep '"action":"msg"' "$flake_update_logs" | grep '"level":1' | sed -e s/^@nix// | jq .msg -r | grep -v 'warning:' | \
    sed -e 's/\x1b\[[0-9;]*m//g' # removes ansi color characters (NO_COLOR=true doesn't work for internal-json logs)
}

# shellcheck disable=SC2154
git remote add github "$gitRemoteUrl"
git fetch github

git branch "$prBranch" "github/${baseBranch}"
git checkout "$prBranch"

nix flake update --log-format internal-json 2> "$flake_update_logs"

title="Automated flake inputs updated"

updated_files=$(git status -s | wc -l)

echo "$updated_files files updated:"
git status -s

if [ "$updated_files" == "0" ]; then
  echo "No change, good bye!"
  cleanup 0

elif [ "$updated_files" == "1" ]; then
  extract_logs
  {
    echo "Changes:"
    echo ""
    echo "\`\`\`"
    extract_logs
    echo "\`\`\`"
  } > "$body"

  {
    echo "$title"
    echo ""
    cat "$body"
  } > "$commit_message"

  git add -u flake.lock
  git commit -F "$commit_message" -- flake.lock || cleanup 0

  # shellcheck disable=SC2154
  $checkCommand

  git push --force-with-lease github HEAD
  gh pr create --base "${baseBranch}" --head "$prBranch" --title "$title" --body-file "$body" || echo "PR already present."
  cleanup 0

else
  echo "Other diffs detected, can't update blindly:"
  git status -s
  cleanup 1
fi
