set -e

nix --version

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

working_copy_directory=$(mktemp -d)
body_file=$(mktemp)
commit_message_file=$(mktemp)
flake_update_logs_file=$(mktemp)

title="Automated flake inputs updated"

function cleanup {
  popd
  rm -rf "$working_copy_directory" "$body_file" "$commit_message_file" "$flake_update_logs_file"
  exit "$1"
}

function update_dependencies {
  nix flake update --log-format internal-json 2> "$flake_update_logs_file"
}

function extract_logs {
  grep '"action":"msg"' "$flake_update_logs_file" | grep '"level":1' | sed -e s/^@nix// | jq .msg -r | grep -v 'warning:' | sed -e 's/\x1b\[[0-9;]*m//g'
}

function clone_repository {
  # shellcheck disable=SC2154
  git clone "$localWorkingCopy" "$working_copy_directory"
  pushd "$working_copy_directory"

  # shellcheck disable=SC2154
  git remote add github "$gitRemoteUrl"
  git fetch github

  git branch "$prBranch" "github/${baseBranch}"
  git checkout "$prBranch"
}

function commit_changes {
  {
    echo "Changes:"
    echo ""
    echo "\`\`\`"
    extract_logs
    echo "\`\`\`"
  } > "$body_file"

  {
    echo "$title"
    echo ""
    cat "$body_file"
  } > "$commit_message_file"

  extract_logs

  git add -u flake.lock
  git commit -F "$commit_message_file" -- flake.lock || cleanup 0
}

function create_pull_request {
  git push --force-with-lease github HEAD
  gh pr create --base "${baseBranch}" --head "$prBranch" --title "$title" --body-file "$body_file" || echo "PR already present."
}

function no_changes {
  echo "No change, good bye!"
  cleanup 0
}

function test_and_report_changes {
  commit_changes

  # shellcheck disable=SC2154
  $checkCommand

  create_pull_request
  cleanup 0
}

function too_many_changes {
  echo "Other diffs detected, can't update blindly:"
  git status -s

  cleanup 1
}

clone_repository

update_dependencies

updated_files=$(git status -s | wc -l)

echo "$updated_files files updated:"
git status -s

if [ "$updated_files" == "0" ]; then
  no_changes

elif [ "$updated_files" == "1" ]; then
  test_and_report_changes

else
  too_many_changes
fi
