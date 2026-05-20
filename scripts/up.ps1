param(
  [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {

  if ($NoBuild) {
    docker compose up -d
  } else {
    docker compose up -d --build
  }

  Write-Host "Laboratorio levantado. Esperando a que los servicios generen logs iniciales..."
  Start-Sleep -Seconds 8
  docker compose ps
}
finally {
  Pop-Location
}
