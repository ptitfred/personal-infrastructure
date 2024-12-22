package_name="$1"
target_version="$2"
url="$3"

echo "Checking ${package_name}…"

target_file="pkgs/${package_name}/version.json"

current_version=$(jq -r .version "$target_file")

if [ "$current_version" != "$target_version" ]; then
  echo "New version detected: $target_version"
  hash="$(nix-prefetch-url "$url")"

  jq . > "$target_file" <<- JSON
  {
    "version": "$target_version",
    "sha256": "$hash",
    "url": "$url"
  }
JSON

  git add "$target_file"

  git commit -m "${package_name} v${target_version}" -- "$target_file"
else
  echo All good
fi
