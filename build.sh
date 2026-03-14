#!/bin/bash
# =============================================================================
# Script:       build.sh
# Description:  Bootstraps the Spark platform by resolving Maven dependencies,
#               building Docker images, and cleaning up dangling artifacts.
# Usage:        ./build.sh
# Dependencies: maven, docker, docker compose
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"


echo "========================================="
echo "        Spark Platform Bootstrap"
echo "========================================="

# ─── Directory setup ──────────────────────────────────────────────────────────

echo "Creating necessary directories..."
mkdir -p \
  ${SCRIPT_DIR}/conf \
  ${SCRIPT_DIR}/scripts \
  ${SCRIPT_DIR}/data

echo "Directories ready."

# ─── Maven build ──────────────────────────────────────────────────────────────
# Resolves dependencies and packages JARs required by the Spark runtime image.

echo ""
echo "-----------------------------------------"
echo "   Maven build (dependency resolution)"
echo "-----------------------------------------"

cd ${SCRIPT_DIR}

if ! command -v mvn >/dev/null 2>&1; then
  echo "[ERROR] Maven not installed."
  exit 1
fi

mvn clean package

echo "Maven build completed."
echo "JARs generated in target/jars"

# ─── Docker installation check ────────────────────────────────────────────────

echo ""
echo "-----------------------------------------"
echo "    Checking Docker installation"
echo "-----------------------------------------"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker not installed."
  exit 1
fi

# ─── Container build ──────────────────────────────────────────────────────────

echo ""
echo "-----------------------------------------"
echo "    Building the containers"
echo "-----------------------------------------"
echo ""

docker compose -f ${COMPOSE_FILE} up -d --build

# ─── Cleanup ──────────────────────────────────────────────────────────────────
# Removes dangling images left behind by the build process.

DANGLING=$(docker images -f "dangling=true" -q)

if [[ -n "$DANGLING" ]]; then
  echo ""
  echo "-----------------------------------------"
  echo "    [INFO] removing extra images..."
  echo "-----------------------------------------"
  echo ""
  docker rmi $DANGLING
fi

echo ""
echo "========================================="
echo "           Platform is ready"
echo "========================================="
