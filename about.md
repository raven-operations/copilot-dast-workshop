# 📖 Acerca del Workshop

> Página de detalles complementaria del [README.md](./README.md) principal.
> Aquí encontrarás información profunda sobre los servicios, runtimes,
> puertos, red y el flujo de ejecución manual del laboratorio DAST.

---

## 🎯 Contexto

Este laboratorio existe para demostrar un flujo **DevSecOps real** con dos aplicaciones vulnerables y un escáner **DAST (Dynamic Application Security Testing)**. El propósito educativo es que, usando **GitHub Copilot Chat** como acelerador, un desarrollador pueda:

1. **Descubrir** vulnerabilidades reales con OWASP ZAP.
2. **Interpretar** el reporte de ZAP con la ayuda de Copilot.
3. **Remediar** con dos estrategias: fix en el código (cuando el código es propio) y mitigación con reverse proxy (cuando no lo es).
4. **Verificar** con un segundo escaneo.
5. **Automatizar** todo el ciclo con GitHub Actions.

---

## 🧱 Servicios del laboratorio

| Servicio           | Runtime / Imagen           | Puerto  | Perfil       | Uso en el workshop                                   |
| ------------------ | -------------------------- | ------- | ------------ | ---------------------------------------------------- |
| `vulnerable-api`   | Node.js 20 + Express       | 4000    | (siempre)    | Target del **Escenario código propio** (Paso 3).     |
| `juice-shop`       | `bkimminich/juice-shop:v20.1.1` | 3000    | (siempre)    | Target del **Escenario sin código** (Paso 4).        |
| `proxy`            | `caddy:2.11.4-alpine`      | 8080    | `hardened`   | Reverse proxy con security headers (Paso 4).         |
| `zap`              | `ghcr.io/zaproxy/zaproxy:2.17.0` | (interno) | `scan`   | Escáner DAST invocado bajo demanda.                  |

Todos los servicios comparten la red bridge `dast-lab`, por lo que ZAP puede resolver `http://vulnerable-api:4000`, `http://juice-shop:3000` y `http://proxy:8080` por nombre de servicio (sin exponer puertos entre ellos).

---

## 🚀 Ejecución manual paso a paso

### Paso 1. Clonar el repositorio y cambiar de rama

```bash
git clone https://github.com/<tu-usuario>/copilot-dast-workshop.git
cd copilot-dast-workshop
git checkout main-copilot-workshop
```

### Paso 2. Abrir el proyecto en VS Code

```bash
code .
```

Asegurate de que **GitHub Copilot** esté activo (icono en la barra inferior debe verse encendido).

### Paso 3. Verificar Docker Desktop

```bash
docker --version
docker compose version
docker ps
```

`docker ps` debe funcionar sin errores. Si no, abrí Docker Desktop.

### Paso 4. Levantar los servicios permanentes

```bash
docker compose up -d
docker compose ps
```

Estados esperados:

- `vulnerable-api` → `running` (healthy)
- `juice-shop` → `running` (healthy)

### Paso 5. Verificar cada endpoint manualmente

**vulnerable-api:**

```bash
curl -s http://localhost:4000/health
# → {"status":"ok"}

curl -s http://localhost:4000/
# → banner con la lista de endpoints
```

**juice-shop:** abrí <http://localhost:3000> en tu navegador. Deberías ver la home de OWASP Juice Shop.

### Paso 6. Ejecutar un primer escaneo baseline

```bash
./scripts/scan.sh baseline http://juice-shop:3000
```

Los reportes aparecen en `reports/`:

- `zap-baseline-juice-shop_3000.html`
- `zap-baseline-juice-shop_3000.json`
- `zap-baseline-juice-shop_3000.md`

---

## 🔬 Detalle de los endpoints vulnerables

La aplicación `vulnerable-api` expone deliberadamente **4 vulnerabilidades canónicas** del OWASP Top 10. Cada una está aislada en un archivo separado para que Copilot Chat pueda enfocarse en el fix sin ruido.

| Endpoint            | Vuln.              | OWASP Top 10 | Archivo                                        | Fix esperado                                        |
| ------------------- | ------------------ | ------------ | ---------------------------------------------- | --------------------------------------------------- |
| `GET /users/search` | SQL Injection      | A03:2021     | `app-vulnerable-api/src/routes/users.js`       | Prepared statements con `?`                         |
| `GET /greet`        | Reflected XSS      | A03:2021     | `app-vulnerable-api/src/routes/greet.js`       | Función `escapeHtml` propia                          |
| `GET /ping`         | Command Injection  | A03:2021     | `app-vulnerable-api/src/routes/ping.js`        | `execFile` + regex de validación de host            |
| `GET /files`        | Path Traversal     | A01:2021     | `app-vulnerable-api/src/routes/files.js`       | `path.resolve` + verificación de prefijo `BASE_DIR` |

Guía de remediación paso a paso: [README.md § Paso 3](./README.md#-paso-3-remediar-vulnerabilidades-en-código-con-copilot).

---

## ⚙️ Configuración de OWASP ZAP

- Reglas de scaneo: [`zap/rules.tsv`](./zap/rules.tsv) — formato TSV que marca cada regla como `IGNORE`, `WARN` o `FAIL`. Copilot puede ayudarte a modificarla en base a los hallazgos.
- Salida: los tres formatos (HTML, JSON, Markdown) se generan en [`reports/`](./reports/). Están **gitignored** para que cada participante genere los suyos.
- Modos:
  - **baseline** — pasivo, ~2 min, detecta headers faltantes / config incorrecta.
  - **full-scan** — activo, 2–30 min según target, envía payloads reales de SQLi/XSS/etc.

Documentación oficial de ZAP:

- [ZAP Baseline Scan](https://www.zaproxy.org/docs/docker/baseline-scan/)
- [ZAP Full Scan](https://www.zaproxy.org/docs/docker/full-scan/)
- [Referencia de alertas](https://www.zaproxy.org/docs/alerts/)

---

## 🔒 Política de reproducibilidad

Todas las imágenes de terceros y dependencias están **pineadas a versiones exactas** para que las tablas antes/después del workshop se puedan reproducir hoy y dentro de un año.

| Componente                            | Versión pineada          | Ubicación                                        |
| ------------------------------------- | ------------------------ | ------------------------------------------------ |
| OWASP Juice Shop (imagen)             | `v20.1.1`                | `docker-compose.yml`                             |
| OWASP ZAP (imagen)                    | `2.17.0`                 | `docker-compose.yml` + `_dast-reusable.yml`      |
| Caddy (imagen)                        | `2.11.4-alpine`          | `docker-compose.yml`                             |
| Node.js (imagen base)                 | `20.20-slim`             | `app-vulnerable-api/Dockerfile`                  |
| Dependencias npm de `vulnerable-api`  | `package-lock.json`      | `app-vulnerable-api/package-lock.json` (`npm ci`) |
| GitHub Actions oficiales              | Semver mayor (`@v4` etc.) | `.github/workflows/*.yml`                       |

El workflow [`validate`](.github/workflows/validate.yml) falla si alguna `image:` de `docker-compose.yml` usa un tag móvil (`latest`, `stable`, `edge`), o si `package.json` y `package-lock.json` están desincronizados.

---

## 🛑 Advertencia de seguridad

> [!WARNING]
> `vulnerable-api` y `juice-shop` contienen vulnerabilidades **explotables reales**. NO los expongas fuera de tu red local durante el workshop.
>
> - No hagas port-forwarding a Internet.
> - No los levantes en un servidor productivo.
> - Al finalizar, ejecutá `docker compose down -v` para limpiar todo.

---

## 🌐 Referencias externas

- [OWASP DevSecOps Guideline — DAST](https://owasp.org/www-project-devsecops-guideline/latest/02b-Dynamic-Application-Security-Testing)
- [OWASP Top 10:2021](https://owasp.org/Top10/)
- [MDN — HTTP Security Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)
- [Caddy Server Documentation](https://caddyserver.com/docs/)
- [GitHub Copilot Chat en VS Code](https://code.visualstudio.com/docs/copilot/copilot-chat)

---

Volvé al [README.md principal](./README.md) para continuar con el workshop.
