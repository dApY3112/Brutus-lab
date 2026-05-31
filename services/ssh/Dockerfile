FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd /etc/ssh/sshd_config.d

COPY entrypoint-vuln.sh /usr/local/bin/entrypoint-vuln.sh
COPY entrypoint-secured.sh /usr/local/bin/entrypoint-secured.sh
RUN chmod +x /usr/local/bin/entrypoint-vuln.sh /usr/local/bin/entrypoint-secured.sh

EXPOSE 22

