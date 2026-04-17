#!/bin/bash
# =============================================================================
# Script:       minio_setup.sh
# Description:  Ensures required directory structure for MinIO persistence.
#               Creates the data directory if it does not exist.
#               Skips execution if the directory is already present.
# Usage:        ./minio_setup.sh
# Dependencies: none
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

cd ${SCRIPT_DIR}

# Skip Maven build if target directory already exists.
if [ -d "data" ]; then
  exit 0
fi

# ─── Directory setup ──────────────────────────────────────────────────────────
# Creates the required directory for MinIO data persistence.

echo "Creating minIO necessary directories..."
mkdir -p ${SCRIPT_DIR}/data
echo "MinIO directory setup completed."
