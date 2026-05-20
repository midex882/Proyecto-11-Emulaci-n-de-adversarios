#!/usr/bin/env bash
set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
NGINX_CONFIG="/etc/nginx/nginx.conf"

sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication no/' "$SSHD_CONFIG"
grep -q '^PasswordAuthentication no' "$SSHD_CONFIG" || printf '\nPasswordAuthentication no\n' >> "$SSHD_CONFIG"

sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin no/' "$SSHD_CONFIG"
grep -q '^PermitRootLogin no' "$SSHD_CONFIG" || printf '\nPermitRootLogin no\n' >> "$SSHD_CONFIG"

grep -q '^MaxAuthTries 3' "$SSHD_CONFIG" || printf '\nMaxAuthTries 3\n' >> "$SSHD_CONFIG"

if ! grep -Eq '^[[:space:]]*server_tokens off;' "$NGINX_CONFIG"; then
  sed -i '/http {/a \    server_tokens off;\n    add_header X-Content-Type-Options nosniff always;\n    add_header X-Frame-Options DENY always;' "$NGINX_CONFIG"
fi

nginx -t
nginx -s reload || true
pkill -HUP sshd || true

echo "target hardening applied"
