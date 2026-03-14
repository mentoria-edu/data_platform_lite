#!/bin/bash
# =============================================================================
# Script:       start_platform.sh
# Description:  Single entry point for managing the Spark platform lifecycle.
#               Detects the current state of the environment and takes the
#               appropriate action: build, start, or scale workers.
# Usage:        ./start_platform.sh [--workers <number>]
#               --workers <number>  Scale Spark workers (between 3 and 12).
#                                   If omitted, platform starts with the
#                                   default defined in docker-compose.yml.
# Dependencies: docker, docker compose, build.sh, change_amount_worker.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BUILD="${SCRIPT_DIR}/build.sh"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
SCALE_WORKER="${SCRIPT_DIR}/change_amount_worker.sh"

# Collect image and container state upfront to drive flow decisions below.
COMPOSE_IMAGES=$(docker compose -f "${COMPOSE_FILE}" config --images | sort -u)
LOCAL_IMAGES=$(docker images --format "{{.Repository}}" | sort -u)
RUNNING_CONTAINERS=$(docker compose -f "${COMPOSE_FILE}" ps --status running --format "{{.Name}}")

# ─── Build ────────────────────────────────────────────────────────────────────
# Triggered when compose images are not found locally.
# Delegates entirely to build.sh which handles Maven, Docker, and cleanup.

if ! echo "$LOCAL_IMAGES" | grep -qF "$COMPOSE_IMAGES"; then
  echo ""
  echo "[ERROR] Images not found, running build..."
  echo ""
  bash ${BUILD}
  echo ""
  echo "========================================="
  echo "  Platform is running"
  echo "========================================="
  echo "Spark Master UI  : http://localhost:8083"
  echo "Spark Worker UI  : http://localhost:8084"
  echo "Spark History UI : http://localhost:18080"
  echo "MinIO Console    : http://localhost:9001"
  echo "MinIO API        : http://localhost:9000"
  echo "========================================="
  exit 0
fi

# ─── Start ────────────────────────────────────────────────────────────────────
# Triggered when images exist but no containers are currently running.
# --no-build skips image rebuild since images are already available.

if [[ -z "$RUNNING_CONTAINERS" ]]; then
  echo ""
  echo "[INFO] Starting platform..."
  echo ""
  docker compose -f ${COMPOSE_FILE} up -d --no-build
  echo ""
  echo "========================================="
  echo "  Platform is running"
  echo "========================================="
  echo "Spark Master UI  : http://localhost:8083"
  echo "Spark Worker UI  : http://localhost:8084"
  echo "Spark History UI : http://localhost:18080"
  echo "MinIO Console    : http://localhost:9001"
  echo "MinIO API        : http://localhost:9000"
  echo "========================================="
  exit 0
fi

# ─── Scale ────────────────────────────────────────────────────────────────────
# Triggered when --workers is provided with a value and the platform is running.
# Delegates validation and execution to change_amount_worker.sh.

if [[ "$1" == "--workers" && -n "$2" ]]; then
  echo ""
  echo "[INFO] changing the number of workers..."
  echo ""
  bash ${SCALE_WORKER} "$@"
  echo ""
  exit 0
fi
