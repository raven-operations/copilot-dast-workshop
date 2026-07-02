#!/usr/bin/env bash
# Levanta el laboratorio DAST (OWASP Juice Shop) usando Docker Compose.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

echo "[start] Levantando OWASP Juice Shop..."
docker compose up -d

echo "[start] Servicios en ejecución:"
docker compose ps

echo ""
echo "[start] Listo. Abre http://localhost:3000 en tu navegador."
