#!/bin/bash
# Make an unattended Pi come back by itself.
set -euo pipefail

# poweroff and halt become reboot (undo before moving the Pi: remove both links)
ln -sf /usr/lib/systemd/system/reboot.target /etc/systemd/system/poweroff.target
ln -sf /usr/lib/systemd/system/reboot.target /etc/systemd/system/halt.target
systemctl daemon-reload

# hardware watchdog: reset if systemd stops responding for 15 s (applies after reboot)
sed -i 's/^#\?RuntimeWatchdogSec=.*/RuntimeWatchdogSec=15s/' /etc/systemd/system.conf

# reboot 10 s after a kernel panic
echo 'kernel.panic = 10' > /etc/sysctl.d/99-reboot-on-panic.conf
sysctl -p /etc/sysctl.d/99-reboot-on-panic.conf
