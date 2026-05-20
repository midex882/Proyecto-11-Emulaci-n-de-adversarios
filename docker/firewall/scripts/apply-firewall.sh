#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-detect}"
WAN_NET="${WAN_NET:-172.30.10.0/24}"
DMZ_NET="${DMZ_NET:-172.30.20.0/24}"
TARGET_IP="${TARGET_IP:-172.30.20.10}"
LOG_FILE="/var/log/project11/firewall.log"

mkdir -p "$(dirname "$LOG_FILE")"

iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s "$DMZ_NET" -m conntrack --ctstate NEW -j ACCEPT

if [[ "$MODE" == "mitigate" ]]; then
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 80 \
    -m string --algo bm --string "../" -j DROP
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 80 \
    -m string --algo bm --string "%2e%2e" -j DROP

  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 22 \
    -m conntrack --ctstate NEW \
    -m recent --name P11_SSH --update --seconds 60 --hitcount 4 -j DROP
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 22 \
    -m conntrack --ctstate NEW \
    -m recent --name P11_SSH --set -j ACCEPT

  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p udp --dport 53 \
    -m hashlimit --hashlimit 10/second --hashlimit-burst 20 \
    --hashlimit-mode srcip --hashlimit-name P11_DNS -j ACCEPT
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p udp --dport 53 -j DROP

  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p icmp \
    -m limit --limit 3/second --limit-burst 6 -j ACCEPT
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p icmp -j DROP
else
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 22 -j ACCEPT
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p udp --dport 53 -j ACCEPT
  iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p icmp -j ACCEPT
fi

iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp -j DROP
iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p udp -j DROP

iptables-save > /etc/project11-iptables.rules

{
  echo "=== $(date -Is) firewall mode: $MODE ==="
  echo "WAN_NET=$WAN_NET DMZ_NET=$DMZ_NET TARGET_IP=$TARGET_IP"
  iptables -S FORWARD
} >> "$LOG_FILE"
