#!/bin/bash
#
# quake-terminal.sh
#
# Copyright (c) 2025 Michael Cramp
#
# This file is part of https://github.com/msftsecurityteam/linux_quake_terminal,
# and is made available under the terms of the MIT License. See the LICENSE file
# in the root of this repository for more information.
#

TERMINAL_CLASS="kitty_launcher"
WINDOW_ID=$(xdotool search --classname $TERMINAL_CLASS)

if [ -z "$WINDOW_ID" ]; then
  kitty --name kitty_launcher --start-as minimized
fi

ANIMATION_DURATION=0.0625
MAX_HEIGHT_PERCENT=30
ANIMATION_STEPS=30
MIN_HEIGHT_PERCENT=1

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

# Toggle the dropdown terminal
toggle_terminal() {
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
      xdotool windowsize "$WINDOW_ID" 100% "$i%"
      sleep $(awk "BEGIN {print $ANIMATION_DURATION / $ANIMATION_STEPS}")
    done
    # Minimize the window
    xdotool windowunmap "$WINDOW_ID"
  else
    # Expand from current height to maximum height
    for ((i = CURRENT_HEIGHT_PERCENT; i <= MAX_HEIGHT_PERCENT; i++)); do
      xdotool windowsize "$WINDOW_ID" 100% "$i%"
      sleep $(awk "BEGIN {print $ANIMATION_DURATION / $ANIMATION_STEPS}")
    done
  fi
}

toggle_terminal
