FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      iproute2 \
      iptables \
      jq \
      netcat-openbsd \
      nftables \
      procps \
      suricata \
      tcpdump \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/suricata/rules /var/log/project11 /var/log/suricata

COPY suricata/project11.rules /etc/suricata/rules/project11.rules
COPY scripts/*.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/firewall-entrypoint.sh"]
