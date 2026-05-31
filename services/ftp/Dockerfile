FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY vsftpd-vuln.conf /etc/vsftpd/vsftpd-vuln.conf
COPY vsftpd-secured.conf /etc/vsftpd/vsftpd-secured.conf
COPY entrypoint-vuln.sh /usr/local/bin/entrypoint-vuln.sh
COPY entrypoint-secured.sh /usr/local/bin/entrypoint-secured.sh
RUN chmod +x /usr/local/bin/entrypoint-vuln.sh /usr/local/bin/entrypoint-secured.sh

EXPOSE 21 30000-30009

