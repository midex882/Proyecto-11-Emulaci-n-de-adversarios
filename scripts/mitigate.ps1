$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {

  docker compose exec firewall /usr/local/bin/apply-firewall.sh mitigate
  docker compose exec target /usr/local/bin/harden-target.sh
  Write-Host "Mitigaciones aplicadas en el cortafuegos y en el servidor protegido."
}
finally {
  Pop-Location
}
