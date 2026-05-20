$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
  docker compose down -v
}
finally {
  Pop-Location
}
