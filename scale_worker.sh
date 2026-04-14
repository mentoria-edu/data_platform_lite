#!/bin/bash
# =============================================================================
# Script:       scale_worker.sh
# Description:  Manages the Spark platform lifecycle — starts, restarts, and
#               scales worker containers. Uses docker compose up which handles
#               building images if needed, starting stopped containers, and
#               scaling workers without interrupting existing ones.
# Usage:        ./scale_worker.sh [-w <number> | --workers <number>]
#               -w, --workers  Number of Spark workers to run (between 1 and 12).
#                              Defaults to 2 if not provided.
# Dependencies: docker, docker compose
# Notes:        The minimum of 2 workers is guaranteed by deploy.replicas
#               in docker-compose.yml when no flag is provided.
# =============================================================================

set -e

# Default number of workers used when --workers flag is not provided.
MIN_WORKERS=1
MAX_WORKERS=12
SPARK_WORKERS=2

# ─── Flag capture ─────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    -w|--workers) 
      if [[ -n "$2" ]]; then
        SPARK_WORKERS="$2"
        shift 2
      else
        shift 1
      fi
    ;;
    *)
      echo "[ERROR] Unknown argument: $1"
      exit 1
    ;;
  esac
done

# ─── Value validation ─────────────────────────────────────────────────────────

# Ensures the value is a positive integer.
if [[ ! "$SPARK_WORKERS" =~ ^[0-9]+$ ]]; then
  echo "[ERROR] The value of -w or --workers must be a positive integer."
  exit 1
fi

# Ensures the value is within the allowed range.
if [[ ("$SPARK_WORKERS" -lt "$MIN_WORKERS" || "$SPARK_WORKERS" -gt "$MAX_WORKERS") ]]; then
  echo "[ERROR] The value of --workers must be between ${MIN_WORKERS} and ${MAX_WORKERS}."
  exit 1
fi

# ─── Scale ────────────────────────────────────────────────────────────────────
# docker compose up handles all scenarios:
# - Builds images if they do not exist locally.
# - Starts containers if they are stopped.
# - Scales workers to the desired count without recreating existing containers.

docker compose up -d --scale spark-worker="${SPARK_WORKERS}"
