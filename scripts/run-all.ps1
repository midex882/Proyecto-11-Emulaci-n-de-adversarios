$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {

  docker compose down -v
  & "$PSScriptRoot\up.ps1"
  & "$PSScriptRoot\emulate.ps1" -Phase before
  & "$PSScriptRoot\collect-evidence.ps1"
  Copy-Item -Force (Join-Path $root "evidence\firewall-summary.txt") (Join-Path $root "evidence\firewall-summary-before.txt") -ErrorAction SilentlyContinue
  Copy-Item -Force (Join-Path $root "evidence\firewall-alerts.tsv") (Join-Path $root "evidence\firewall-alerts-before.tsv") -ErrorAction SilentlyContinue

  & "$PSScriptRoot\mitigate.ps1"
  docker compose exec firewall sh -lc ': > /var/log/suricata/eve.json'
  & "$PSScriptRoot\emulate.ps1" -Phase after
  & "$PSScriptRoot\collect-evidence.ps1"
  Copy-Item -Force (Join-Path $root "evidence\firewall-summary.txt") (Join-Path $root "evidence\firewall-summary-after.txt") -ErrorAction SilentlyContinue
  Copy-Item -Force (Join-Path $root "evidence\firewall-alerts.tsv") (Join-Path $root "evidence\firewall-alerts-after.tsv") -ErrorAction SilentlyContinue

  Write-Host "Ejecucion completa. Revisa la carpeta evidence/."
}
finally {
  Pop-Location
}
