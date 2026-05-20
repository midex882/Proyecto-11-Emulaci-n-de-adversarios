# Ansible

Playbook de bastionado para aplicar contramedidas despues de la fase de deteccion.

## Ejecucion local

Si Ansible esta instalado en el host:

```bash
cd ansible
ansible-playbook site.yml
```

## Ejecucion con Docker

Tambien puede ejecutarse desde un contenedor con Ansible montando el socket de Docker:

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/work \
  -w /work/ansible \
  cytopia/ansible:latest ansible-playbook site.yml
```

El playbook actua sobre los contenedores `p11-firewall` y `p11-target`.

En Windows, si el montaje del socket de Docker no esta disponible desde un contenedor Linux, ejecuta el playbook desde WSL o con Ansible instalado en el host.

