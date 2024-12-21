version="$(gh release list --repo obsidianmd/obsidian-releases --exclude-drafts --exclude-pre-releases -L 1 --json name | jq -r .[].name)"

filename="obsidian-${version}.tar.gz";
url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/${filename}";
hash="$(nix-prefetch-url "$url")"

target_file="pkgs/obsidian/version.json"

jq . > "$target_file" <<- JSON
  {
    "version": "$version",
    "sha256": "$hash",
    "url": "$url"
  }
JSON

git add "$target_file"

git commit -m "Obsidian v$version" -- "$target_file"
