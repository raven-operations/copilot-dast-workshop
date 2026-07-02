# Reproducibilidad del laboratorio

> Este laboratorio es material didáctico: los hallazgos de escaneo,
> comparaciones antes/después y prompts de Copilot **solo tienen valor
> si son reproducibles**. Este documento describe la política de pinning
> y verificación del repo.

---

## Política de pinning

Toda dependencia externa está pineada a una versión exacta. No usamos
tags móviles (`latest`, `stable`, `edge`).

| Componente                        | Versión pineada              | Dónde                                       |
| --------------------------------- | ---------------------------- | ------------------------------------------- |
| OWASP Juice Shop (imagen)         | `v20.1.1`                    | [`docker-compose.yml`](../docker-compose.yml) |
| OWASP ZAP (imagen)                | `2.17.0`                     | [`docker-compose.yml`](../docker-compose.yml) + [`_dast-reusable.yml`](../.github/workflows/_dast-reusable.yml) |
| Caddy (imagen)                    | `2.11.4-alpine`              | [`docker-compose.yml`](../docker-compose.yml) |
| Node.js (imagen base)             | `20.20-slim`                 | [`app-vulnerable-api/Dockerfile`](../app-vulnerable-api/Dockerfile) |
| Dependencias npm de vulnerable-api| `package-lock.json`          | [`app-vulnerable-api/package-lock.json`](../app-vulnerable-api/package-lock.json) |
| GitHub Actions oficiales          | Semver mayor (`@v4`, `@v0.14.0`) | `.github/workflows/*.yml`                |

### Por qué así

- **Imágenes de terceros (`juice-shop`, `zaproxy`)**: cambian hallazgos
  del escaneo entre releases; un pin exacto garantiza que la tabla
  "antes/después" del workshop se pueda reproducir el año que viene.
- **Base runtime (`node`, `caddy`)**: cambios menores de parche podrían
  afectar comportamiento sutil (headers, TLS, buffering).
- **npm (`package-lock.json` + `npm ci`)**: sin lockfile, `npm install`
  puede resolver deps transitivas distintas y cambiar la superficie de
  vulnerabilidad de la app.
- **Actions oficiales por semver mayor**: buen balance entre seguridad
  (los mantiene GitHub) y menor mantenimiento. Para hardening estricto
  se puede pinear al SHA.

---

## Cómo se verifica

El workflow [`validate`](../.github/workflows/validate.yml) corre en
cada push y PR y falla si:

1. Falta cualquier archivo esperado del laboratorio.
2. `docker-compose.yml` no es válido (`docker compose config --quiet`).
3. Alguna `image:` en `docker-compose.yml` usa un tag móvil
   (`latest`, `stable`, `edge`).
4. `package.json` y `package-lock.json` de `vulnerable-api` están
   desincronizados (`npm ci --dry-run`).

Los dos workflows DAST ([`dast-juice-shop`](../.github/workflows/dast-juice-shop.yml),
[`dast-vulnerable-api`](../.github/workflows/dast-vulnerable-api.yml))
usan el mismo pin y publican los reportes como artifacts, para que
cualquiera pueda comparar sus escaneos locales con los de CI.

---

## Cómo actualizar una versión

Cuando quieras subir una versión pineada:

1. Cambiá el tag en el archivo correspondiente
   (`docker-compose.yml`, `Dockerfile` o `_dast-reusable.yml`).
2. Corré el smoke test local:
   ```bash
   docker compose pull
   docker compose up -d --build
   docker inspect --format '{{.State.Health.Status}}' juice-shop vulnerable-api
   ```
3. Corré un baseline y comparalo con el anterior:
   ```bash
   ./scripts/scan.sh baseline http://juice-shop:3000
   diff -u reports/zap-baseline-juice-shop_3000.md.old \
           reports/zap-baseline-juice-shop_3000.md
   ```
4. Si hay cambios en los hallazgos, actualizá las tablas de
   [`docs/Remediation.md`](Remediation.md) o
   [`docs/RemediationCode.md`](RemediationCode.md) que citan
   números específicos (`WARN 7 → 4`, etc.).
5. Actualizá la fila correspondiente en la tabla de este documento.

---

## Fecha de la última verificación

- **2026-07-02** — Todas las imágenes pineadas y build de
  `vulnerable-api` validado con `npm ci` sobre el lockfile actual.
