#!/bin/bash
input=$(cat)

green='\033[32m'
yellow='\033[33m'
red='\033[31m'
dim='\033[2m'
reset='\033[0m'
sep=" ${dim}│${reset} "

color_from() {
  local value=$1 yellow_from=$2 red_from=$3
  if [ "$value" -ge "$red_from" ]; then printf '%s' "$red"
  elif [ "$value" -ge "$yellow_from" ]; then printf '%s' "$yellow"
  else printf '%s' "$green"; fi
}

model=$(echo "$input" | jq -r '.model.display_name // "?"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
line="$model"
[ -n "$effort" ] && line+=" $effort"

tokens=$(echo "$input" | jq -r '.context_window.current_usage // {} | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
bar_tokens=200000
bar_cells=10
filled=$(( tokens / (bar_tokens / bar_cells) ))
[ "$filled" -gt "$bar_cells" ] && filled=$bar_cells
bar=""
for ((i=0; i<bar_cells; i++)); do
  if [ "$i" -lt "$filled" ]; then bar+="▓"; else bar+="░"; fi
done
line+="${sep}$(color_from "$tokens" 140000 "$bar_tokens")${bar} $(( tokens / 1000 ))k${reset}"

cache=$(echo "$input" | jq -r '.prompt_cache // empty | if .warm then "warm" else "cold" end')
if [ "$cache" = "cold" ]; then
  recache=$(echo "$input" | jq -r '.prompt_cache.recache_tokens_if_cold // 0')
  line+="${sep}cache ${red}cold ~$(( recache / 1000 ))k${reset}"
elif [ "$cache" = "warm" ]; then
  expires_at=$(echo "$input" | jq -r '.prompt_cache.expires_at')
  seconds_left=$(( expires_at - $(date +%s) ))
  minutes_left=$(( (seconds_left + 59) / 60 ))
  warn_minutes=15
  if [ "$minutes_left" -le "$warn_minutes" ]; then cache_color=$yellow; else cache_color=$green; fi
  line+="${sep}cache ${cache_color}${minutes_left}m${reset}"
fi

week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | floor')
[ -n "$week" ] && line+="${sep}week $(color_from "$week" 50 75)${week}%${reset}"

hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | floor')
[ -n "$hour" ] && line+="${sep}5h $(color_from "$hour" 50 75)${hour}%${reset}"

printf "%b\n" "$line"
