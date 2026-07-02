# OWASP ZAP

Configuración de OWASP ZAP para el laboratorio.

- [`rules.tsv`](rules.tsv): política de reglas (TAB-separated) que se
  monta como `/zap/config/rules.tsv` en el contenedor. Marca reglas
  como `IGNORE`, `WARN` o `FAIL` para ajustar la severidad del
  reporte sin editar la app.

Se consume desde:

- [`scripts/scan.sh`](../scripts/scan.sh) para escaneos locales.
- [`.github/workflows/_dast-reusable.yml`](../.github/workflows/_dast-reusable.yml)
  para escaneos en CI (parámetro `rules_file_name`).