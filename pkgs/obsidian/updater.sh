version="$(gh release list --repo obsidianmd/obsidian-releases --exclude-drafts --exclude-pre-releases -L 1 --json name | jq -r .[].name)"
url="https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
generic-updater obsidian "${version}" "${url}"
