#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/log/project11 /var/log/suricata /var/run/suricata
touch /var/log/project11/firewall.log

sysctl -w net.ipv4.ip_forward=1 >/dev/null || true

/usr/local/bin/apply-firewall.sh "${FIREWALL_MODE:-detect}"

suricata -D \
  -i eth0 \
  -i eth1 \
  -l /var/log/suricata \
  -S /etc/suricata/rules/project11.rules \
  -k none \
  --set vars.address-groups.HOME_NET="[${DMZ_NET:-172.30.20.0/24}]" \
  --set vars.address-groups.EXTERNAL_NET="[${WAN_NET:-172.30.10.0/24}]" \
  || true

echo "$(date -Is) firewall container ready in mode=${FIREWALL_MODE:-detect}" >> /var/log/project11/firewall.log

tail -F /var/log/project11/firewall.log /var/log/suricata/eve.json

