#!/usr/bin/env bash
set -euo pipefail

LAB_USER="labuser"
LAB_PASSWORD="Use-A-Strong-Password-For-SSH-2026!"

if ! id "$LAB_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$LAB_USER"
fi

echo "$LAB_USER:$LAB_PASSWORD" | chpasswd
mkdir -p /run/sshd

cat >/etc/ssh/sshd_config.d/99-brutus-lab.conf <<'EOF'
PasswordAuthentication yes
PermitRootLogin no
ChallengeResponseAuthentication no
MaxAuthTries 3
UsePAM yes
EOF

exec /usr/sbin/sshd -D -e

