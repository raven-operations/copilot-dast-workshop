#!/usr/bin/env bash
# Detiene los contenedores del laboratorio sin eliminar redes ni volumenes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

echo "[stop] Deteniendo contenedores..."
docker compose stop

echo "[stop] Estado actual:"
docker compose ps
