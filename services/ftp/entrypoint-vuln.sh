#!/usr/bin/env bash
set -euo pipefail

LAB_USER="ftpuser"
LAB_PASSWORD="ftp12345"

if ! id "$LAB_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$LAB_USER"
fi

echo "$LAB_USER:$LAB_PASSWORD" | chpasswd
mkdir -p "/home/$LAB_USER/upload" /var/run/vsftpd/empty
chown -R "$LAB_USER:$LAB_USER" "/home/$LAB_USER"

cp /etc/vsftpd/vsftpd-vuln.conf /etc/vsftpd.conf
exec /usr/sbin/vsftpd /etc/vsftpd.conf

