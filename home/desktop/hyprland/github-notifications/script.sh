function print_result {
  jq . --unbuffered --compact-output <<-JSON
    {
      "text": "$1",
      "class": "$2",
      "tooltip": "$3",
      "percentage": $4
    }
	JSON
}

function fetch {
  curl -H "Authorization: Bearer $TOKEN" "https://api.github.com/notifications?unread=true&per_page=100" 2>/dev/null || echo "offline"
}

result=$(fetch)

if [ "$result" == "offline" ]
then
  print_result offline offline Offline 0
else
  count=$(echo "$result" | jq length)
  if [[ $count -eq 0 ]]
  then
    print_result 0 hidden "All good" 0
  else
    print_result "$count" active "$count notifications" 100
  fi
fi
