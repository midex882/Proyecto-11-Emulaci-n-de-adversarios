param(
  [ValidateSet("before", "after", "manual")]
  [string]$Phase = "manual"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {

  docker compose exec adversary /usr/local/bin/emulate.sh $Phase
}
finally {
  Pop-Location
}
