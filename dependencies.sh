#!/bin/bash
# =============================================================================
# Script:       build.sh
# Description:  Resolves Maven dependencies and packages JARs required by the
#               Spark runtime image. Skips execution if target directory
#               already exists, avoiding unnecessary rebuilds.
# Usage:        ./build.sh
# Dependencies: maven
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Skip Maven build if target directory already exists.
if [ -d "target" ]; then
  exit 0
fi

# ─── Directory setup ──────────────────────────────────────────────────────────

echo "Creating necessary directories..."
mkdir -p \
  ${SCRIPT_DIR}/conf \
  ${SCRIPT_DIR}/data

echo "Directories ready."

# ─── Maven build ──────────────────────────────────────────────────────────────
# Resolves dependencies and packages JARs required by the Spark runtime image.

cd ${SCRIPT_DIR}

mvn clean package

echo "Maven build completed."
echo "JARs generated in target/jars"
