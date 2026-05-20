# Proyecto 11: Emulacion de adversarios

## Objetivo

Validar una infraestructura a través de la emulacion de comportamientos típicos de actores maliciosos, deteccion en logs del cortafuegos, aplicacion de contramedidas y comprobacion automatizada.

## Infraestructura

El laboratorio se ejecuta con Docker y contiene tres equipos:

- `p11-adversary`: equipo atacante en la red WAN.
- `p11-firewall`: cortafuegos entre WAN y DMZ.
- `p11-target`: servidor protegido en DMZ.

Fragmento principal de red:

```yaml
networks:
  wan:
    ipam:
      config:
        - subnet: 172.30.10.0/24
  dmz:
    ipam:
      config:
        - subnet: 172.30.20.0/24
```

El servidor protegido queda en DMZ:

```yaml
target:
  container_name: p11-target
  networks:
    dmz:
      ipv4_address: 172.30.20.10
```

El cortafuegos enruta entre WAN y DMZ:

```yaml
firewall:
  container_name: p11-firewall
  privileged: true
  sysctls:
    net.ipv4.ip_forward: "1"
  networks:
    wan:
      ipv4_address: 172.30.10.254
    dmz:
      ipv4_address: 172.30.20.254
```

## Despliegue

Ejecucion completa:

```powershell
.\scripts\run-all.ps1
```

El script realiza:

1. Construccion de imagenes.
2. Arranque de contenedores.
3. Emulacion inicial.
4. Recogida de logs.
5. Aplicacion de mitigaciones.
6. Emulacion posterior.
7. Generacion de evidencias.

## Emulacion

La emulacion se ejecuta desde `p11-adversary`.

Comportamientos generados:

- Escaneo TCP de puertos.
- Fuerza bruta SSH.
- Reconocimiento ICMP.
- Peticiones HTTP sospechosas.
- Rafaga de consultas DNS.
- Intentos a puertos no publicados.

Fragmento:

```bash
nmap -Pn -sT -p 1-1024 "$TARGET_IP"
```

```bash
for i in $(seq 1 8); do
  sshpass -p "wrong-password-$i" ssh student@"$TARGET_IP" "id"
done
```

```bash
curl --path-as-is "http://$TARGET_IP/../../etc/passwd"
dig @"$TARGET_IP" "replay-$i.project11.local" A
```

## Deteccion

Suricata se ejecuta en el cortafuegos y registra eventos en:

```text
/var/log/suricata/eve.json
```

Consulta usada para extraer alertas:

```bash
jq -r '
  select(.event_type=="alert")
  | [.timestamp, .src_ip, .dest_ip, (.dest_port // "-"), .proto, .alert.signature]
  | @tsv
' /var/log/suricata/eve.json
```

Reglas principales de Suricata:

```text
alert tcp $EXTERNAL_NET any -> $HOME_NET any \
(msg:"P11 TCP service discovery or unauthorized port attempt"; sid:1100001;)
```

```text
alert tcp $EXTERNAL_NET any -> $HOME_NET 22 \
(msg:"P11 SSH brute force pattern"; threshold:type both, track by_src, count 4, seconds 60; sid:1100003;)
```

```text
alert dns $EXTERNAL_NET any -> $HOME_NET 53 \
(msg:"P11 DNS burst or suspicious replay"; threshold:type both, track by_src, count 20, seconds 30; sid:1100006;)
```

Alertas esperadas:

- `P11 TCP service discovery or unauthorized port attempt`
- `P11 SSH brute force pattern`
- `P11 ICMP reconnaissance from WAN`
- `P11 DNS burst or suspicious replay`
- `P11 HTTP raw path traversal marker`
- `P11 HTTP encoded traversal marker`

## Identificacion

| Firma | Comportamiento |
|---|---|
| `P11 TCP service discovery...` | Escaneo de servicios |
| `P11 SSH brute force pattern` | Fuerza bruta SSH |
| `P11 ICMP reconnaissance...` | Reconocimiento ICMP |
| `P11 DNS burst...` | Rafaga DNS |
| `P11 HTTP raw path traversal marker` | Path traversal HTTP |

## Mitigacion

El cortafuegos aplica politica restrictiva:

```bash
iptables -P FORWARD DROP
```

Servicios permitidos:

```bash
iptables -A FORWARD -s "$WAN_NET" -d "$TARGET_IP" -p tcp --dport 80 -j ACCEPT
```

Limitacion de SSH:

```bash
iptables -A FORWARD -p tcp --dport 22 \
  -m recent --update --seconds 60 --hitcount 4 --name P11_SSH -j DROP
```

Limitacion DNS:

```bash
iptables -A FORWARD -p udp --dport 53 \
  -m hashlimit --hashlimit 10/second --hashlimit-burst 20 \
  --hashlimit-mode srcip --hashlimit-name P11_DNS -j ACCEPT
```

Bloqueo HTTP de path traversal:

```bash
iptables -A FORWARD -p tcp --dport 80 \
  -m string --algo bm --string "../" -j DROP
```

## Bastionado del servidor

SSH:

```text
PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
```

Nginx:

```text
server_tokens off;
add_header X-Content-Type-Options nosniff always;
add_header X-Frame-Options DENY always;
```

## Validacion

Comprobacion:

```powershell
.\scripts\inspec.ps1
```

Controles validados:

- Politica `FORWARD DROP`.
- Reglas de limitacion SSH y DNS.
- Reglas Suricata cargadas.
- Logs con alertas `P11`.
- SSH endurecido.
- Nginx endurecido.
- Servicios previstos activos.

Resultado obtenido:

```text
7 successful controls
21 successful tests
0 failures
```

## Evidencias

Archivos generados:

```text
evidence/firewall-summary-before.txt
evidence/firewall-summary-after.txt
evidence/firewall-alerts-before.tsv
evidence/firewall-alerts-after.tsv
evidence/iptables-rules.txt
```

## Conclusion

El laboratorio despliega una red con cortafuegos, genera trafico adversario controlado, registra eventos en Suricata, identifica comportamientos no deseados, aplica contramedidas con `iptables` y bastionado del host, y valida el resultado con InSpec.
