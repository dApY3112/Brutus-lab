#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker was not found; nothing to stop."
  exit 0
fi

if docker compose version >/dev/null 2>&1; then
  docker compose -f docker-compose.vuln.yml down --remove-orphans >/dev/null 2>&1 || true
  docker compose -f docker-compose.secured.yml down --remove-orphans >/dev/null 2>&1 || true
fi

echo "Lab containers stopped. Results were left in ./results."

