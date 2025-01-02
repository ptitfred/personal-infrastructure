classPattern=$1
shift 1

function focus {
  i3-msg "[class=\"$classPattern\"] focus" || echo anyway
}

focus
"$@" &

xdotool search --sync --pid "$!"
focus

fg 1
