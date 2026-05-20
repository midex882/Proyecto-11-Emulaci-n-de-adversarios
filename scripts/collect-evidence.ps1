$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$evidence = Join-Path $root "evidence"
New-Item -ItemType Directory -Force -Path $evidence | Out-Null
Push-Location $root
try {

  docker compose exec firewall /usr/local/bin/analyze-logs.sh /var/log/suricata/eve.json /tmp/evidence
  docker cp p11-firewall:/tmp/evidence/. $evidence
  docker compose logs --no-color firewall > (Join-Path $evidence "docker-firewall.log")
  docker compose logs --no-color target > (Join-Path $evidence "docker-target.log")

  Write-Host "Evidencias guardadas en $evidence"
}
finally {
  Pop-Location
}
