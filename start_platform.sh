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
MAVEN="${SCRIPT_DIR}/conf/maven/maven_setup.sh"
MINIO="${SCRIPT_DIR}/conf/minio/minio_setup.sh"
SCALE_WORKER="${SCRIPT_DIR}/conf/docker/scale_worker.sh"

# ─── MINIO ────────────────────────────────────────────────────────────────────
# Delegates to minio_setup.sh which runs Minio if data directory does not exist.
# Skips automatically if dependencies are already resolved.

bash ${MINIO}

# ─── Maven ────────────────────────────────────────────────────────────────────
# Delegates to maven_setup.sh which runs Maven if target directory does not exist.
# Skips automatically if dependencies are already resolved.

bash ${MAVEN}

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
