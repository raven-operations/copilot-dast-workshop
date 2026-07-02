#!/usr/bin/env bash
# Elimina contenedores, redes y volumenes creados por el laboratorio.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

echo "[cleanup] Eliminando contenedores, redes y volumenes..."
docker compose down -v --remove-orphans

echo "[cleanup] Laboratorio limpio."
