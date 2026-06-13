#!/usr/bin/env bash

# Script for auto change screen resolution and retoggle wallpaper then resize windows

# Params
readonly OUTPUT='Virtual-1'
readonly TIMEOUT='0.2'

while true; do
  x_info="$(xrandr)"
  now_res=$(grep 'current' <<< "$x_info" | cut -f 2 -d ',')
  now_res="${now_res#*current}"
  now_res="${now_res// /}"
  res=$(grep -A 1 "$OUTPUT" <<< "$x_info" | awk 'NR==2 {print $1}')

  if [[ "$now_res" != "$res" ]]; then
    # xrandr --output "$OUTPUT"  --mode "$res"
    $HOME/.fehbg
  fi

  sleep "$TIMEOUT"
done;
