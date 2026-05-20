#!/usr/bin/env bash
set +e

TARGET_IP="${TARGET_IP:-172.30.20.10}"
PHASE="${1:-manual}"
OUT="/tmp/project11-emulation-${PHASE}.log"

{
  echo "=== Proyecto 11 adversary emulation: $PHASE ==="
  date -Is
  echo "Target: $TARGET_IP"
  echo

  echo "[1] ICMP reconnaissance"
  ping -c 8 -W 1 "$TARGET_IP"
  echo

  echo "[2] TCP service discovery"
  nmap -Pn -sT -p 1-1024 "$TARGET_IP"
  echo

  echo "[3] SSH brute force pattern"
  for i in $(seq 1 8); do
    sshpass -p "wrong-password-$i" ssh \
      -o PreferredAuthentications=password \
      -o PubkeyAuthentication=no \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=2 \
      student@"$TARGET_IP" "id" </dev/null
  done
  echo

  echo "[4] HTTP suspicious requests"
  curl -m 3 -sS "http://$TARGET_IP/" >/dev/null
  curl --path-as-is -m 3 -sS "http://$TARGET_IP/../../etc/passwd" >/dev/null
  curl --path-as-is -m 3 -sS "http://$TARGET_IP/%2e%2e/%2e%2e/etc/passwd" >/dev/null
  curl -m 3 -sS "http://$TARGET_IP/wp-login.php" >/dev/null
  echo

  echo "[5] DNS burst"
  for i in $(seq 1 40); do
    dig @"$TARGET_IP" "replay-$i.project11.local" A +time=1 +tries=1 >/dev/null
  done
  echo

  echo "[6] Non-published service attempts"
  for port in 23 25 445 3389 4444 8080; do
    nc -vz -w 1 "$TARGET_IP" "$port"
  done
  echo

  date -Is
  echo "=== End emulation ==="
} 2>&1 | tee "$OUT"

sleep 5
