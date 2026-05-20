#!/usr/bin/env bash
set -euo pipefail

DMZ_NET="${DMZ_NET:-172.30.20.0/24}"
FIREWALL_WAN_IP="${FIREWALL_WAN_IP:-172.30.10.254}"

ip route add "$DMZ_NET" via "$FIREWALL_WAN_IP" 2>/dev/null || true

exec "$@"

