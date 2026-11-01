#!/bin/bash
# /usr/local/sbin/auto-update.sh
# Daily full upgrade. Reboots only when a newer kernel of the *running* flavor is
# installed (Pi OS ships rpi-2712 for the Pi 5 and rpi-v8 for the Pi 4).
# Kernel packages are held separately because the Hailo driver is built per kernel:
#   dpkg -l | grep -E "^ii\s+linux-(image|headers)" | awk '{print $2}' | xargs sudo apt-mark hold
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
LOG=/var/log/auto-update.log
{
  echo "=== $(date) ==="
  apt-get update
  apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade
  apt-get clean
  # No autoremove here: it removed desktop packages once. Run it by hand after reading the plan.
  RUNNING=$(uname -r)
  FLAVOR=${RUNNING##*-}
  LATEST=$(ls -1 /lib/modules | grep -- "-${FLAVOR}\$" | sort -V | tail -1)
  if [ -n "$LATEST" ] && [ "$RUNNING" != "$LATEST" ]; then
    echo "New $FLAVOR kernel $LATEST (running $RUNNING), rebooting in 1 minute"
    /sbin/shutdown -r +1 "Rebooting after updates"
  fi
} >> "$LOG" 2>&1
