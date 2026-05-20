FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      dnsmasq \
      iproute2 \
      nginx \
      openssh-server \
      procps \
      sudo \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash student \
    && echo "student:student" | chpasswd \
    && mkdir -p /run/sshd /var/www/html \
    && printf '<h1>Proyecto 11</h1><p>Servidor protegido en DMZ</p>\n' > /var/www/html/index.html

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 22 53/udp 80

ENTRYPOINT ["/usr/local/bin/target-entrypoint.sh"]
