# InSpec

Perfiles incluidos:

- `profiles/firewall`: valida politica de cortafuegos, reglas de mitigacion y evidencias Suricata.
- `profiles/target`: valida bastionado del servidor protegido.

## Ejecucion con Docker

```powershell
.\scripts\inspec.ps1
```

## Ejecucion local alternativa

Si InSpec esta instalado en el host:

```bash
inspec exec inspec/profiles/firewall -t docker://p11-firewall
inspec exec inspec/profiles/target -t docker://p11-target
```

