#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${BRUTUS_IMAGE:-brutus-mini-lab-brutus:latest}"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is required to use the Brutus runner container." >&2
  exit 1
fi

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "ERROR: Brutus runner image '$IMAGE' was not found. Run ./setup.sh first." >&2
  exit 1
fi

exec docker run --rm --network host -v "$ROOT_DIR:/lab" -w /lab "$IMAGE" "$@"

