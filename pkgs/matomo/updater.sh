target_file="pkgs/matomo/version.json"

target_version=$(http https://builds.matomo.org/LATEST_5X)

current_version=$(jq -r .version $target_file)

if [ "$current_version" != "$target_version" ]; then
  echo "New version detected: $target_version"
  url="https://builds.matomo.org/matomo-${target_version}.tar.gz"
  hash=$(nix-prefetch-url "$url")
  jq . > "$target_file" <<-JSON
  {
    "version": "$target_version",
    "sha256": "$hash",
    "url": "$url"
  }
JSON

  git add "$target_file"

  git commit -m "Matomo v${target_version}" -- "$target_file"
else
  echo All good
fi
