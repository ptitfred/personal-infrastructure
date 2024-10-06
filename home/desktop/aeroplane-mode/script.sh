status=$(nmcli radio wifi)

case "$status" in
  enabled) nmcli radio wifi off;;
  *)       nmcli radio wifi on;;
esac
