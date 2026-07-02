#!/usr/bin/env bash
# Ejecuta un escaneo DAST (baseline por defecto) con OWASP ZAP.
#
# Uso:
#   ./scripts/scan.sh                                 # baseline vs juice-shop
#   ./scripts/scan.sh full                            # full scan vs juice-shop
#   ./scripts/scan.sh baseline http://proxy:8080     # baseline vs proxy endurecido
#   ./scripts/scan.sh full     http://proxy:8080     # full scan vs proxy endurecido

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

MODE="${1:-baseline}"
TARGET="${2:-http://juice-shop:3000}"

# Slug del target para nombrar los reportes (ej. "juice-shop_3000", "proxy_8080")
TARGET_SLUG="$(echo "${TARGET}" | sed -E 's|^https?://||; s|[/:]|_|g; s|_+$||')"
REPORT_BASE="zap-${MODE}-${TARGET_SLUG}"

echo "[scan] Verificando que juice-shop esté corriendo..."
if ! docker compose ps --status running --services | grep -q '^juice-shop$'; then
  echo "[scan] juice-shop no está activo. Levantándolo..."
  docker compose up -d juice-shop
fi

# Si el target apunta al proxy, asegurarse de que esté arriba.
if [[ "${TARGET}" == *"proxy"* ]]; then
  if ! docker compose ps --status running --services | grep -q '^proxy$'; then
    echo "[scan] proxy no está activo. Levantándolo (profile hardened)..."
    docker compose --profile hardened up -d proxy
  fi
fi

mkdir -p reports

case "${MODE}" in
  baseline)
    echo "[scan] Ejecutando ZAP baseline scan contra ${TARGET}..."
    docker compose --profile scan run --rm zap \
      zap-baseline.py \
        -t "${TARGET}" \
        -c /zap/config/rules.tsv \
        -r "${REPORT_BASE}.html" \
        -J "${REPORT_BASE}.json" \
        -w "${REPORT_BASE}.md" \
        -I
    ;;
  full)
    echo "[scan] Ejecutando ZAP full scan contra ${TARGET} (puede tardar 10-30 min)..."
    docker compose --profile scan run --rm zap \
      zap-full-scan.py \
        -t "${TARGET}" \
        -c /zap/config/rules.tsv \
        -r "${REPORT_BASE}.html" \
        -J "${REPORT_BASE}.json" \
        -w "${REPORT_BASE}.md" \
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
