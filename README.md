# Proyecto 11: Emulacion de adversarios

## Contenedores

- `p11-adversary`: equipo atacante.
- `p11-firewall`: cortafuegos con iptables y Suricata.
- `p11-target`: servidor protegido en DMZ.

## Scripts

- `scripts/run-all.ps1`: Para ejecutar todo desde cero, construir los contenedores, etc (llama a los demás).
- `scripts/up.ps1`: construye y levanta los contenedores.
- `scripts/emulate.ps1`: lanza la emulacion de ataques desde el adversary.
- `scripts/mitigate.ps1`: aplica las contramedidas en firewall y servidor.
- `scripts/collect-evidence.ps1`: guarda logs y resumenes en la carpeta evidence/.
- `scripts/inspec.ps1`: comprueba los controles de InSpec.
- `scripts/down.ps1`: apaga y elimina los contenedores y volumenes.

## Evidencias generadas

Despues de ejecutar el run-all, se pueden ver las pruebas en:

- `evidence/firewall-summary-before.txt`
- `evidence/firewall-summary-after.txt`
- `evidence/firewall-alerts-before.tsv`
- `evidence/firewall-alerts-after.tsv`
- `evidence/iptables-rules.txt`
