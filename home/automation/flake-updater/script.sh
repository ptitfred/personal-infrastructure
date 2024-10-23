set -e

# shellcheck disable=SC2154
NIX_CONFIG="extra-access-tokens = github.com=$(cat "$githubTokenFile")"
export NIX_CONFIG

dir=$(mktemp -d)
logs=$(mktemp)

nix --version

# shellcheck disable=SC2154
git clone "$localWorkingCopy" "$dir"
pushd "$dir"

function cleanup {
  popd
  rm -rf "$dir" "$logs"
  exit "$1"
}

# shellcheck disable=SC2154
git remote add github "$gitRemoteUrl"
git fetch github

git branch automated-inputs-update github/main
git checkout automated-inputs-update

{
  echo "Automated inputs updated"
  echo ""
  echo "Changes:"
  echo ""
  echo "\`\`\`"
} > "$logs"
nix flake update | tee -a "$logs"
echo "\`\`\`" >> "$logs"

git add -u flake.lock
git commit -F "$logs" -- flake.lock || cleanup 0

other_diffs=$(git status -s | wc -l)
if [ "$other_diffs" == "0" ]; then
  cat "$logs"
  # shellcheck disable=SC2154
  $checkCommand
  git push --force-with-lease github HEAD
  cleanup 0
else
  echo "Other diffs detected, can't update blindly:"
  git status -s
  cleanup 1
fi
