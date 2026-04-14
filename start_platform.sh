#!/bin/bash
# =============================================================================
# Script:       start_platform.sh
# Description:  Single entry point for managing the Spark platform lifecycle.
#               Ensures Maven dependencies are resolved before delegating
#               platform startup and worker scaling to scale_worker.sh.
# Usage:        ./start_platform.sh [-w <number> | --workers <number>]
#               -w, --workers  Number of Spark workers to run (between 1 and 12).
#                              If omitted, platform starts with the default
#                              defined in docker-compose.yml.
# Dependencies: docker, docker compose, build.sh, scale_worker.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BUILD="${SCRIPT_DIR}/build.sh"
SCALE_WORKER="${SCRIPT_DIR}/scale_worker.sh"

# ─── Build ────────────────────────────────────────────────────────────────────
# Delegates to build.sh which runs Maven if target directory does not exist.
# Skips automatically if dependencies are already resolved.

bash ${BUILD}

# ─── Scale ────────────────────────────────────────────────────────────────────
# Delegates entirely to scale_worker.sh which handles flag parsing, validation,
# and platform lifecycle via docker compose up.

echo ""
bash ${SCALE_WORKER} "$@"
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
