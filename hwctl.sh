#!/usr/bin/env bash

# Copyright (c) 2026 Mate Karcsics
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Brightness control was inspired by Amine Abdz's KDE Better Brightness Controls
# https://github.com/mimminou/KDE_Better_Brightness_Controls

set -e

# ---------- HELP ----------

compact_help() {
  cat <<EOF
Usage:
  $(basename "$0") (--brightness|-b | --volume|-v) (--up|-u | --down|-d | --min | --max)

Try --help for more information.
EOF
}

full_help() {
  cat <<EOF
Brightnes and volume controls for Microsoft Surface Laptop SE on Arch with KDE Plasma
Brightnes control depends qdbus, that's included in the package: qt5-tools
This can be installed with:

pacman -S qt5-tools

Usage:
  $(basename "$0") MODE ACTION

Modes (required, choose one):
  -b, --brightness     Control screen brightness
  -v, --volume         Control audio volume

Actions (required, choose one):
  -u, --up             Increase value
  -d, --down           Decrease value
      --min            Set to minimum
      --max            Set to maximum

Other:
  -h, --help           Show this help message

Examples:
  $(basename "$0") -b -u
  $(basename "$0") --volume --max

Copyright (c) 2026 Mate Karcsics - GPL-3.0-or-later
EOF
}

# ---------- ACTION FUNCTIONS ----------

brightness() {
# Get initial values
NEXTVALUE=0
CURRENT_BRIGHTNESS=$(</sys/class/backlight/intel_backlight/brightness head -n1)
MAX_BRIGHTNESS=$(</sys/class/backlight/intel_backlight/max_brightness head -n1)
# Convert Max and Current Brightness values where the MAX value is 10000
CURRENT_BRIGHTNESS=$(($CURRENT_BRIGHTNESS / 96 * 10 ))
MAX_BRIGHTNESS=$(($MAX_BRIGHTNESS / 96 * 10 ))
# Configure Steps (100 = 1% brightness change)
STEP=400
case "$1" in
  up)
  if [ $CURRENT_BRIGHTNESS -lt $MAX_BRIGHTNESS ]; then
      NEXTVALUE=$(($CURRENT_BRIGHTNESS + $STEP))
      echo "Brightness increased to: $NEXTVALUE"
      qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness $NEXTVALUE
  fi
  ;;
  down)
      NEXTVALUE=$(($CURRENT_BRIGHTNESS - $STEP))
      if [ $NEXTVALUE -lt 100 ]; then
          NEXTVALUE=100
      fi
      echo "Brightness decreased to $NEXTVALUE"
      qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness $NEXTVALUE
  ;;
  min)
      echo "Brightness decreased to Minimum"
      qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness 50
  ;;
  max)
      echo "Brightness increased to Maximum"
      qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl.setBrightness $MAX_BRIGHTNESS
  ;;
  *)    echo "Invalid brightness action"; exit 1 ;;
esac
}

volume() {
# Change this if needed
SINK=@DEFAULT_SINK@ 
# Step size for volume change
STEP=5 
VOLUME=$(pactl get-sink-volume $SINK | awk '{print $5}' | tr -d '%')
case "$1" in
  up)
      NEW_VOLUME=$((VOLUME + STEP))
      if [ "$NEW_VOLUME" -gt 100 ]; then
          NEW_VOLUME=100
      fi
      pactl set-sink-volume $SINK "${NEW_VOLUME}%"
      echo "Volume increased to $NEW_VOLUME%"
  ;;
  down)
      NEW_VOLUME=$((VOLUME - STEP))
      if [ "$NEW_VOLUME" -lt 0 ]; then
          NEW_VOLUME=0
      fi
      pactl set-sink-volume $SINK "${NEW_VOLUME}%"
      echo "Volume decreased to $NEW_VOLUME%"
  ;;
  min)
      pactl set-sink-volume $SINK "1%"
      echo "Volume decreased to 1%"
  ;;
  max)
      pactl set-sink-volume $SINK "100%"
      echo "Volume increased to 100%"
  ;;
  *)   
      echo "Invalid volume action";
      exit 1
      ;;
esac
}

# ---------- ARG PARSING ----------

MODE=""
ACTION=""

PARSED=$(getopt -o bvudh \
  --long brightness,volume,up,down,min,max,help \
  -- "$@") || { compact_help; exit 1; }

eval set -- "$PARSED"

while true; do
  case "$1" in
    -b|--brightness) MODE="brightness"; shift ;;
    -v|--volume)     MODE="volume"; shift ;;
    -u|--up)         ACTION="up"; shift ;;
    -d|--down)       ACTION="down"; shift ;;
    --min)           ACTION="min"; shift ;;
    --max)           ACTION="max"; shift ;;
    -h|--help)       full_help; exit 0 ;;
    --) shift; break ;;
    *) compact_help; exit 1 ;;
  esac
done

# ---------- VALIDATION ----------

if [[ -z "$MODE" || -z "$ACTION" ]]; then
  compact_help
  exit 1
fi

# ---------- DISPATCH ----------

"$MODE" "$ACTION"
