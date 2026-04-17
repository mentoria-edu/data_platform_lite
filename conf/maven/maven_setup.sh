#!/bin/bash
# =============================================================================
# Script:       maven_setup.sh
# Description:  Resolves Maven dependencies and packages JARs required by the
#               Spark runtime image. Skips execution if target directory
#               already exists, avoiding unnecessary rebuilds.
# Usage:        ./maven_setup.sh
# Dependencies: maven
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

cd ${SCRIPT_DIR}

# Skip Maven build if target directory already exists.
if [ -d "target" ]; then
  exit 0
fi

# ─── Maven build ──────────────────────────────────────────────────────────────
# Resolves dependencies and packages JARs required by the Spark runtime image.

mvn -f ${SCRIPT_DIR}/pom.xml clean package
echo "Maven build completed."
