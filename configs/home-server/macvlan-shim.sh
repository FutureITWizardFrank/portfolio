#!/usr/bin/env bash
# macvlan network for containers, plus a host-side shim so the host can reach them.
# Linux blocks traffic between a host and its own macvlan children on the parent
# interface; the shim is a second macvlan interface on the host with a /32 address
# and one /32 route per container. Addresses are examples.
set -euo pipefail

PARENT=eno1
SUBNET=10.0.10.0/24
GATEWAY=10.0.10.1
SHIM_IP=10.0.10.2/32
CONTAINERS=(10.0.10.30 10.0.10.53 10.0.10.65 10.0.10.102)

docker network create -d macvlan \
  --subnet "$SUBNET" --gateway "$GATEWAY" \
  -o parent="$PARENT" macvlan_net

# Persistent through NetworkManager (RHEL)
nmcli connection add type macvlan con-name macvlan-shim ifname macvlan-shim \
  macvlan.parent "$PARENT" macvlan.mode bridge \
  ipv4.method manual ipv4.addresses "$SHIM_IP" ipv6.method disabled

for ip in "${CONTAINERS[@]}"; do
  nmcli connection modify macvlan-shim +ipv4.routes "$ip/32"
done

nmcli connection up macvlan-shim
ip route show dev macvlan-shim
