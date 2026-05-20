FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      curl \
      dnsutils \
      iproute2 \
      iputils-ping \
      jq \
      netcat-openbsd \
      nmap \
      openssh-client \
      sshpass \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/adversary-entrypoint.sh"]

