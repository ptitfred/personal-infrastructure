location="$HOME/Pictures/screenshots"
mkdir -p "$location"
scrot -s "$location/%Y-%m-%d_\$sx\$h.png" -e "xclip -sel c -t image/png \$f"
