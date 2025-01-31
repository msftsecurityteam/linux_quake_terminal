#!/bin/bash
#
# quake-term.sh
#
# Copyright (c) 2025 Michael Cramp
#
# This file is part of https://github.com/msftsecurityteam/linux_quake_terminal,
# and is made available under the terms of the MIT License. See the LICENSE file
# in the root of this repository for more information.
#

TERMINAL_CLASS="kitty_launcher" # special classname for your quake terminal
ANIMATION_DURATION=0.0625       # time (seconds) you would like it to take to open the terminal
ANIMATION_STEPS=30              # can leave this largely untouched
MIN_HEIGHT_PERCENT=0            # keep this at 1 (unless you know what you're doing)
MAX_HEIGHT_PERCENT=30           # adjust this higher or lower to change the size of your quake-terminal

WINDOW_ID=$(xdotool search --classname $TERMINAL_CLASS)
if [ -z "$WINDOW_ID" ]; then
  # Start the terminal if it isn't already running.
  kitty --name "$TERMINAL_CLASS" --start-as minimized --detach
  # Leave a short delay to let the terminal initialize.
  sleep 0.1
  WINDOW_ID=$(xdotool search --classname $TERMINAL_CLASS)
fi

# Check if a window is minimized (Withdrawn)
is_withdrawn() {
  xprop -id "$WINDOW_ID" WM_STATE | egrep -q "Withdrawn|Iconic"
}

# Get the current height percentage
get_current_height_percent() {
  GEOMETRY_OUTPUT=$(xdotool getwindowgeometry "$1")
  HEIGHT=$(echo "$GEOMETRY_OUTPUT" | awk '/Geometry:/ { split($2, dimensions, "x"); print dimensions[2] }')
  SCREEN_HEIGHT=$(xdotool getdisplaygeometry | awk '{ print $2 }')

  if [ "$SCREEN_HEIGHT" -eq 0 ]; then
    echo "0"
    return
  fi

  HEIGHT_PERCENT=$(awk "BEGIN { printf \"%.0f\", ($HEIGHT / $SCREEN_HEIGHT) * 100 }")

  echo "$HEIGHT_PERCENT"
}

# Get current monitor width
get_monitor_width() {
  eval $(xdotool getmouselocation --shell)
  ACTIVE_MONITOR=$(xrandr --query | grep " connected" | awk -v x=$X -v y=$Y '{
    split($3, coords, "+");
    split(coords[1], dimensions, "x");
    if (x >= coords[2] && x <= coords[2] + dimensions[1] && y >= coords[3] && y <= coords[3] + dimensions[2]) {
      print $1";"dimensions[1]
      exit
    }
  }')
  echo ${ACTIVE_MONITOR##*;}
}

# Toggle the dropdown terminal
toggle_terminal() {
  LOCAL_WIDTH=$(get_monitor_width)

  if is_withdrawn "$WINDOW_ID"; then
    # If minimized, start at 1% height
    xdotool windowmap "$WINDOW_ID"
    CURRENT_HEIGHT_PERCENT=$MIN_HEIGHT_PERCENT
  else
    CURRENT_HEIGHT_PERCENT=$(get_current_height_percent "$WINDOW_ID")
  fi

  if [ "$CURRENT_HEIGHT_PERCENT" -eq "$MAX_HEIGHT_PERCENT" ]; then
    # If at maximum height, contract to minimum and minimize
    for ((i = MAX_HEIGHT_PERCENT; i >= MIN_HEIGHT_PERCENT; i--)); do
      xdotool windowsize "$WINDOW_ID" "$LOCAL_WIDTH" "$i%"
      sleep $(awk "BEGIN {print $ANIMATION_DURATION / $ANIMATION_STEPS}")
    done
    # Minimize the window
    xdotool windowunmap "$WINDOW_ID"
  else
    # Expand from current height to maximum height
    for ((i = CURRENT_HEIGHT_PERCENT; i <= MAX_HEIGHT_PERCENT; i++)); do
      xdotool windowsize "$WINDOW_ID" "$LOCAL_WIDTH" "$i%"
      sleep $(awk "BEGIN {print $ANIMATION_DURATION / $ANIMATION_STEPS}")
    done
  fi
}

toggle_terminal
