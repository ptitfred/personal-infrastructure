function detectWindowId {
  local pid="$1"
  xdotool search --sync --onlyvisible --pid "$pid" | tail -1
}

function centerAndFloating {
  echo "Centering $1"
  i3-msg "[id=$1] floating enable, move position center"
}

nm-connection-editor &
centerAndFloating "$(detectWindowId $!)"
fg
