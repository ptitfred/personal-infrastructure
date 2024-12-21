target_file="pkgs/obsidian/version.json"

target_version="$(gh release list --repo obsidianmd/obsidian-releases --exclude-drafts --exclude-pre-releases -L 1 --json name | jq -r .[].name)"

current_version=$(jq -r .version $target_file)

if [ "$current_version" != "$target_version" ]; then
  echo "New version detected: $target_version"

  filename="obsidian-${target_version}.tar.gz";
  url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${target_version}/${filename}";
  hash="$(nix-prefetch-url "$url")"

  jq . > "$target_file" <<- JSON
  {
    "version": "$target_version",
    "sha256": "$hash",
    "url": "$url"
  }
JSON

  git add "$target_file"

  git commit -m "Obsidian v${target_version}" -- "$target_file"
else
  echo All good
fi
