#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

COMPOSE_FILE="docker-compose.secured.yml"

die() {
  echo "ERROR: $*" >&2
  exit 1
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
  local name="$1"
  local host="$2"
  local port="$3"

  printf "Waiting for %-12s at %s:%s" "$name" "$host" "$port"
  for _ in $(seq 1 60); do
    if check_port "$host" "$port"; then
      echo " ready"
      return 0
    fi
    printf "."
    sleep 1
  done
  echo
  die "$name did not become reachable on $host:$port."
}

command -v docker >/dev/null 2>&1 || die "docker is required."
docker compose version >/dev/null 2>&1 || die "docker compose is required."

bash "$ROOT_DIR/stop_lab.sh"

echo "Starting secured Brutus mini-lab..."
docker compose -f "$COMPOSE_FILE" up -d --build ssh-secured ftp-secured http-basic-secured

wait_for_port "SSH" "127.0.0.1" "2222"
wait_for_port "FTP" "127.0.0.1" "2121"
wait_for_port "HTTP Basic" "127.0.0.1" "8080"

echo
echo "Secured targets are ready:"
printf "%-14s %-18s %-18s\n" "Protocol" "Target" "Expected with lab wordlist"
printf "%-14s %-18s %-18s\n" "SSH" "127.0.0.1:2222" "no weak credential"
printf "%-14s %-18s %-18s\n" "FTP" "127.0.0.1:2121" "no weak credential"
printf "%-14s %-18s %-18s\n" "HTTP Basic" "127.0.0.1:8080" "no weak credential"
echo
echo "Next: ./exploit_test.sh --secured"

