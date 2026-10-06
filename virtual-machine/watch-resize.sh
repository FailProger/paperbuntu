#!/usr/bin/env bash

# Script for auto retoggle wallpaper on x-resize

# Params
readonly TIMEOUT='0.2'

last_res=''

while true; do
  x_info="$(xrandr)"
  cur_res=$(grep 'current' <<< "$x_info" | cut -f 2 -d ',')
  cur_res="${cur_res#*current}"
  cur_res="${cur_res// /}"

  if [[ "$cur_res" != "$last_res" ]]; then
    "$HOME"/.fehbg
    polybar-msg cmd restart

    last_res="$cur_res"
  fi

  sleep "$TIMEOUT"
done;

