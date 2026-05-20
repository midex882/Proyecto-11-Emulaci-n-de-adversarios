$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {

  Write-Host "Ejecutando controles InSpec del cortafuegos..."
  docker run --rm `
    -e CHEF_LICENSE=accept-silent `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -v "${root}/inspec/profiles/firewall:/profiles/firewall" `
    chef/inspec:latest exec /profiles/firewall -t docker://p11-firewall

  Write-Host "Ejecutando controles InSpec del servidor protegido..."
  docker run --rm `
    -e CHEF_LICENSE=accept-silent `
    -v /var/run/docker.sock:/var/run/docker.sock `
    -v "${root}/inspec/profiles/target:/profiles/target" `
    chef/inspec:latest exec /profiles/target -t docker://p11-target

  Write-Host "Si estas en Windows y falla el montaje de /var/run/docker.sock, ejecuta este script desde WSL o instala InSpec en el host."
}
finally {
  Pop-Location
}
