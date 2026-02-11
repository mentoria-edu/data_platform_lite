#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo "========================================="
echo "Spark Platform Bootstrap"
echo "========================================="

# Diretórios padrão
echo "Creating necessary directories..."
mkdir -p \
  ${SCRIPT_DIR}/conf \
  ${SCRIPT_DIR}/scripts \
  ${SCRIPT_DIR}/data

echo "Directories ready."

echo ""
echo "-----------------------------------------"
echo "Step 1 - Maven build (dependency resolution)"
echo "-----------------------------------------"

cd ${SCRIPT_DIR}

if ! command -v mvn >/dev/null 2>&1; then
  echo "ERROR: Maven not installed."
  exit 1
fi

mvn clean package

if [ $? -ne 0 ]; then
  echo "Maven build failed."
  exit 1
fi

echo "Maven build completed."
echo "JARs generated in target/jars"

echo ""
echo "-----------------------------------------"
echo "Step 2 - Docker installed (Spark runtime)"
echo "-----------------------------------------"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker not installed."
  exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker-compose not installed."
  exit 1
fi

echo ""
echo "-----------------------------------------"
echo "Step 3 - Platform startup (docker-compose)"
echo "-----------------------------------------"

docker compose -f ${SCRIPT_DIR}/docker-compose.yml up -d --build

if [ $? -ne 0 ]; then
  echo "Docker compose failed."
  exit 1
fi

echo ""
echo "========================================="
echo "Platform is running"
echo "========================================="
echo "Spark Master UI  : http://localhost:8083"
echo "Spark Worker UI  : http://localhost:8084"
echo "Spark History UI : http://localhost:18080"
echo "MinIO Console    : http://localhost:9001"
echo "MinIO API        : http://localhost:9000"
echo "========================================="
