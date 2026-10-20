#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)

tokens=$(( ctx * size / 100 / 1000 ))

if [ "$ctx" -ge 75 ]; then color='\033[31m'
elif [ "$ctx" -ge 50 ]; then color='\033[33m'
else color='\033[32m'; fi
reset='\033[0m'

filled=$(( ctx / 10 ))
bar=""
for ((i=0; i<10; i++)); do
  if [ $i -lt $filled ]; then bar+="▓"; else bar+="░"; fi
done

line="[$model] ${color}${bar} ${ctx}%${reset} ~${tokens}k ctx"
[ -n "$week" ] && line+="  week ${week}%"
[ -n "$hour" ] && line+="  5h ${hour}%"
printf "%b\n" "$line"
