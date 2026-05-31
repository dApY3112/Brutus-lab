#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required but was not found."
}

echo "[setup] Preparing directories and script permissions..."
mkdir -p "$ROOT_DIR/bin" "$ROOT_DIR/results"

scripts=(
  "$ROOT_DIR/setup.sh"
  "$ROOT_DIR/run_vuln.sh"
  "$ROOT_DIR/run_secured.sh"
  "$ROOT_DIR/stop_lab.sh"
  "$ROOT_DIR/exploit_test.sh"
  "$ROOT_DIR/verify_lab.sh"
  "$ROOT_DIR/tools/run-brutus.sh"
  "$ROOT_DIR/services/ssh/entrypoint-vuln.sh"
  "$ROOT_DIR/services/ssh/entrypoint-secured.sh"
  "$ROOT_DIR/services/ftp/entrypoint-vuln.sh"
  "$ROOT_DIR/services/ftp/entrypoint-secured.sh"
)

chmod +x "${scripts[@]}" 2>/dev/null || true

require_cmd docker
docker compose version >/dev/null 2>&1 || die "docker compose is required."

echo "[setup] Building lab target images..."
docker compose -f docker-compose.vuln.yml build ssh-vuln ftp-vuln http-basic-vuln
docker compose -f docker-compose.secured.yml build ssh-secured ftp-secured http-basic-secured

echo "[setup] Building Brutus runner from the official Praetorian repository release..."
docker build -t brutus-mini-lab-brutus:latest -f tools/Dockerfile.brutus tools

container_id=""
cleanup() {
  if [[ -n "$container_id" ]]; then
    docker rm -f "$container_id" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[setup] Extracting Brutus binary to ./bin/brutus when compatible with the host..."
container_id="$(docker create brutus-mini-lab-brutus:latest)"
docker cp "$container_id:/usr/local/bin/brutus" "$ROOT_DIR/bin/brutus"
docker cp "$container_id:/usr/local/bin/brutus.exe" "$ROOT_DIR/bin/brutus.exe" 2>/dev/null || true
chmod +x "$ROOT_DIR/bin/brutus" "$ROOT_DIR/bin/brutus.exe" 2>/dev/null || true

echo "[setup] Done."
echo "Run ./run_vuln.sh, then ./exploit_test.sh."
