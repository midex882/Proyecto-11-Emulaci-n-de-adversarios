#!/usr/bin/env bash
set -euo pipefail

WAN_NET="${WAN_NET:-172.30.10.0/24}"
FIREWALL_DMZ_IP="${FIREWALL_DMZ_IP:-172.30.20.254}"

ip route add "$WAN_NET" via "$FIREWALL_DMZ_IP" 2>/dev/null || true

mkdir -p /run/sshd

service nginx start
/usr/sbin/sshd

exec dnsmasq --keep-in-foreground --log-queries --log-facility=-

