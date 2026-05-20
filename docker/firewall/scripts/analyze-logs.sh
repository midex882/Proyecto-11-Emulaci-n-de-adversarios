#!/usr/bin/env bash
set -euo pipefail

EVE="${1:-/var/log/suricata/eve.json}"
OUT_DIR="${2:-/evidence}"

mkdir -p "$OUT_DIR"

if [[ ! -s "$EVE" ]]; then
  echo "No hay eventos todavia en $EVE" > "$OUT_DIR/firewall-summary.txt"
  exit 0
fi

jq -r '
  select(.event_type=="alert")
  | [.timestamp, .src_ip, .dest_ip, (.dest_port // "-"), .proto, .alert.signature]
  | @tsv
' "$EVE" > "$OUT_DIR/firewall-alerts.tsv"

{
  echo "Resumen de alertas por firma"
  echo "============================"
  jq -r 'select(.event_type=="alert") | .alert.signature' "$EVE" | sort | uniq -c | sort -nr
  echo
  echo "Primeros eventos"
  echo "==============="
  head -n 20 "$OUT_DIR/firewall-alerts.tsv" || true
} > "$OUT_DIR/firewall-summary.txt"

iptables-save > "$OUT_DIR/iptables-rules.txt"
cp /var/log/project11/firewall.log "$OUT_DIR/firewall-mode-history.log" || true

