#!/bin/bash
# =============================================================================
# Script:       change_amount_worker.sh
# Description:  Scales the number of Spark worker containers in a running
#               cluster without recreating or interrupting existing workers.
# Usage:        ./change_amount_worker.sh --workers <number>
#               <number> must be between 3 and 12.
# Dependencies: docker, docker compose
# Notes:        If --workers is not provided, no action is taken.
#               The minimum of 2 workers is guaranteed by deploy.replicas
#               in docker-compose.yml.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
MIN_WORKERS=3
MAX_WORKERS=12
WORKERS=""

# ─── Flag capture ─────────────────────────────────────────────────────────────

if [[ "$1" == --* && "$1" != "--workers" ]]; then
  echo "[ERROR] Unknown argument: $1"
  exit 1
fi

if [[ "$1" == "--workers" ]]; then
  WORKERS="$2"
fi

# ─── Value validation ─────────────────────────────────────────────────────────
# Both checks include -n to skip validation when --workers was not provided.

if [[ -n "$WORKERS" && ! "$WORKERS" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] The value of --workers must be a positive integer."
  exit 1
fi

if [[ -n "$WORKERS" && ("$WORKERS" -lt "$MIN_WORKERS" || "$WORKERS" -gt "$MAX_WORKERS") ]]; then
  echo "[ERROR] The value of --workers must be between ${MIN_WORKERS} and ${MAX_WORKERS}."
  exit 1
fi

# ─── Scale ────────────────────────────────────────────────────────────────────
# --no-recreate ensures existing healthy workers are not interrupted.
# --no-build skips image rebuild since images are already available.

if [[ -n "$WORKERS" ]]; then
  docker compose -f "${COMPOSE_FILE}" up -d --no-build --no-recreate --scale spark-worker=$WORKERS
  exit 0
fi
