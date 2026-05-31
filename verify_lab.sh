#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

issues=0

fail() {
  echo "FAIL: $*" >&2
  issues=1
}

ok() {
  echo "OK: $*"
}

require_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 found"
  else
    fail "$1 not found"
  fi
}

check_port() {
  local host="$1"
  local port="$2"

  if command -v nc >/dev/null 2>&1; then
    nc -z "$host" "$port" >/dev/null 2>&1
    return $?
  fi

  (exec 3<>"/dev/tcp/${host}/${port}") >/dev/null 2>&1
}

wait_for_port() {
  local label="$1"
  local host="$2"
  local port="$3"

  for _ in $(seq 1 60); do
    if check_port "$host" "$port"; then
      ok "$label listening on $host:$port"
      return 0
    fi
    sleep 1
  done

  fail "$label did not listen on $host:$port"
}

cleanup() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -f docker-compose.vuln.yml down --remove-orphans >/dev/null 2>&1 || true
    docker compose -f docker-compose.secured.yml down --remove-orphans >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "Checking prerequisites..."
require_cmd docker
if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    ok "docker compose works"
  else
    fail "docker compose is not available"
  fi
fi

echo
echo "Checking required files..."
required_files=(
  README.md
  CONTRIBUTIONS.md
  ETHICS.md
  docker-compose.vuln.yml
  docker-compose.secured.yml
  setup.sh
  run_vuln.sh
  run_secured.sh
  stop_lab.sh
  exploit_test.sh
  verify_lab.sh
  Makefile
  .gitignore
  docs/demo_script.md
  docs/architecture.md
  docs/results_template.md
  docs/sources.md
  results/.gitkeep
  wordlists/users_ssh.txt
  wordlists/users_ftp.txt
  wordlists/users_http.txt
  wordlists/passwords_lab.txt
  services/ssh/Dockerfile
  services/ssh/entrypoint-vuln.sh
  services/ssh/entrypoint-secured.sh
  services/ftp/Dockerfile
  services/ftp/vsftpd-vuln.conf
  services/ftp/vsftpd-secured.conf
  services/ftp/entrypoint-vuln.sh
  services/ftp/entrypoint-secured.sh
  services/http-basic/Dockerfile
  services/http-basic/nginx.conf
  services/http-basic/index.html
  services/http-basic/htpasswd-vuln
  services/http-basic/htpasswd-secured
  tools/Dockerfile.brutus
  tools/run-brutus.sh
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    ok "$file exists"
  else
    fail "$file is missing"
  fi
done

echo
echo "Checking executable scripts..."
for script in setup.sh run_vuln.sh run_secured.sh stop_lab.sh exploit_test.sh verify_lab.sh tools/run-brutus.sh; do
  if [[ -x "$script" ]]; then
    ok "$script is executable"
  else
    fail "$script is not executable; run ./setup.sh"
  fi
done

echo
echo "Checking wordlists..."
for list in wordlists/users_ssh.txt wordlists/users_ftp.txt wordlists/users_http.txt wordlists/passwords_lab.txt; do
  if [[ -f "$list" && "$(wc -l <"$list")" -le 20 ]]; then
    ok "$list is tiny"
  else
    fail "$list is missing or too large"
  fi
done

grep -Fxq "password123" wordlists/passwords_lab.txt && ok "SSH weak password is in lab wordlist" || fail "password123 missing"
grep -Fxq "ftp12345" wordlists/passwords_lab.txt && ok "FTP weak password is in lab wordlist" || fail "ftp12345 missing"
grep -Fxq "admin123" wordlists/passwords_lab.txt && ok "HTTP weak password is in lab wordlist" || fail "admin123 missing"

if grep -Fq "Use-A-Strong-Password" wordlists/passwords_lab.txt; then
  fail "secured passwords must not appear in the lab wordlist"
else
  ok "secured passwords are absent from the lab wordlist"
fi

if [[ "$issues" -ne 0 ]]; then
  echo
  echo "Static verification failed before Docker runtime checks."
  exit 1
fi

echo
echo "Validating Compose files..."
docker compose -f docker-compose.vuln.yml config >/dev/null
ok "docker-compose.vuln.yml config is valid"
docker compose -f docker-compose.secured.yml config >/dev/null
ok "docker-compose.secured.yml config is valid"

echo
echo "Starting vulnerable compose for port checks..."
docker compose -f docker-compose.vuln.yml up -d --build ssh-vuln ftp-vuln http-basic-vuln
wait_for_port "SSH vulnerable" "127.0.0.1" "2222"
wait_for_port "FTP vulnerable" "127.0.0.1" "2121"
wait_for_port "HTTP Basic vulnerable" "127.0.0.1" "8080"
docker compose -f docker-compose.vuln.yml down --remove-orphans >/dev/null

echo
echo "Starting secured compose for port checks..."
docker compose -f docker-compose.secured.yml up -d --build ssh-secured ftp-secured http-basic-secured
wait_for_port "SSH secured" "127.0.0.1" "2222"
wait_for_port "FTP secured" "127.0.0.1" "2121"
wait_for_port "HTTP Basic secured" "127.0.0.1" "8080"

echo
if [[ "$issues" -eq 0 ]]; then
  echo "Verification completed successfully."
else
  echo "Verification completed with issues."
fi

exit "$issues"

