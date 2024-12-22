echo "Checking lix-module…"

set +e
dirty_files=$(git status --porcelain | cut -d" " -f3 | grep -c "^flake.\(nix\|lock\)$")
set -e

if [ "$dirty_files" != "0" ]; then
  echo "Dirty files, can't update. Aborting..."
  git status -s
  exit 1
fi

current_url=$(nix flake metadata --json | jq -r '.locks.nodes."lix-module".original.url')
version=$(http "https://git.lix.systems/lix-project/nixos-module/tags.rss" | xq -r .rss.channel.item[0].title)
url="https://git.lix.systems/lix-project/nixos-module/archive/${version}.tar.gz"

if [ "$current_url" != "$url" ]; then
  echo "New version detected: ${version}"
  sed --in-place --expression="s|lix-module.url = \"[^\"]*\"|lix-module.url = \"${url}\"|" flake.nix
  nix flake update lix-module

  git add flake.nix flake.lock

  git commit -m "lix-module v${version}" -- flake.nix flake.lock
else
  echo All good
fi
