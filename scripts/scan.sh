#!/usr/bin/env bash
# Ejecuta un escaneo DAST (baseline por defecto) con OWASP ZAP contra
# la instancia local de Juice Shop.
#
# Uso:
#   ./scripts/scan.sh              # baseline (rápido, pasivo)
#   ./scripts/scan.sh full         # full scan (activo, más lento)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

MODE="${1:-baseline}"

echo "[scan] Verificando que juice-shop esté corriendo..."
if ! docker compose ps --status running --services | grep -q '^juice-shop$'; then
  echo "[scan] juice-shop no está activo. Levantándolo..."
  docker compose up -d juice-shop
fi

mkdir -p reports

case "${MODE}" in
  baseline)
    echo "[scan] Ejecutando ZAP baseline scan..."
    docker compose --profile scan run --rm zap \
      zap-baseline.py \
        -t http://juice-shop:3000 \
        -c /zap/config/rules.tsv \
        -r zap-baseline-report.html \
        -J zap-baseline-report.json \
        -w zap-baseline-report.md \
        -I
    ;;
  full)
    echo "[scan] Ejecutando ZAP full scan (esto puede tardar 10-30 min)..."
    docker compose --profile scan run --rm zap \
      zap-full-scan.py \
        -t http://juice-shop:3000 \
        -c /zap/config/rules.tsv \
        -r zap-full-report.html \
        -J zap-full-report.json \
        -w zap-full-report.md \
        -I
    ;;
  *)
    echo "[scan] Modo desconocido: '${MODE}'. Usa 'baseline' o 'full'." >&2
    exit 2
    ;;
esac

echo ""
echo "[scan] Reportes disponibles en: ${PROJECT_DIR}/reports/"
ls -1 reports/ | sed 's/^/  - /'
