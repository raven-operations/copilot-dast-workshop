# GitHub Copilot + OWASP ZAP (DAST) Workshop

[![validate](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/validate.yml/badge.svg)](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/validate.yml)
[![dast](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast.yml/badge.svg)](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast.yml)

> Laboratorio práctico para aprender a acelerar procesos DevSecOps usando
> **GitHub Copilot** junto con **Dynamic Application Security Testing (DAST)**.

---

## Introducción

Este laboratorio forma parte del workshop **GitHub Copilot + OWASP ZAP (DAST)**.

El objetivo del taller **no** es aprender OWASP ZAP en profundidad, sino
demostrar cómo **GitHub Copilot** puede acelerar significativamente un flujo
DevSecOps al escribir configuraciones, workflows, scripts y remediaciones
relacionadas con seguridad dinámica de aplicaciones.

En esta **primera etapa** trabajaremos únicamente con la aplicación vulnerable
[OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) ejecutándose
localmente mediante Docker Compose. Las etapas posteriores del workshop
integrarán OWASP ZAP y GitHub Actions.

---

## Objetivos

Al finalizar esta primera etapa el participante será capaz de:

- Clonar el repositorio del laboratorio.
- Levantar una aplicación vulnerable con **Docker Compose**.
- Acceder a la aplicación desde el navegador.
- Entender la estructura del laboratorio para futuras integraciones
  (OWASP ZAP + GitHub Actions).

En etapas posteriores del workshop se incorporarán:

- Escaneos DAST automáticos con OWASP ZAP.
- Automatización mediante GitHub Actions.
- Generación de reportes y remediación asistida por Copilot.

---

## Arquitectura

```mermaid
flowchart LR
    Dev["Participante<br>VS Code + Copilot"]
    Compose["Docker Compose"]
    Juice["OWASP Juice Shop<br>contenedor"]
    Browser["Navegador<br>localhost:3000"]
    ZAP["OWASP ZAP<br>profile: scan"]
    Reports[("reports/")]

    Dev -->|docker compose up| Compose
    Compose --> Juice
    Browser --> Juice
    ZAP -->|escanea| Juice
    ZAP -->|reportes| Reports
```

Componentes:

| Componente        | Descripción                                                |
| ----------------- | ---------------------------------------------------------- |
| Docker Compose    | Orquesta los servicios del laboratorio.                    |
| OWASP Juice Shop  | Aplicación web intencionalmente vulnerable.                |
| Navegador         | Punto de acceso del usuario a la aplicación.               |

---

## Requisitos

Antes de iniciar el laboratorio asegúrate de tener instalado:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (con Docker Compose v2).
- [Git](https://git-scm.com/downloads).
- [Visual Studio Code](https://code.visualstudio.com/).
- [GitHub Copilot](https://github.com/features/copilot) habilitado en VS Code.

Verifica tu instalación:

```bash
docker --version
docker compose version
git --version
code --version
```

---

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/clever-devops-tools/copilot-dast-workshop.git
   cd copilot-dast-workshop
   ```

2. Abre el proyecto en Visual Studio Code:

   ```bash
   code .
   ```

3. Asegúrate de que Docker Desktop esté en ejecución.

---

## Ejecución

Levanta el laboratorio con Docker Compose:

```bash
docker compose up -d
```

Alternativamente, puedes usar los scripts incluidos:

- **macOS / Linux:** `./scripts/start.sh`
- **Windows (PowerShell):** `./scripts/start.ps1`

---

## Verificación

1. Comprueba que el contenedor está en ejecución:

   ```bash
   docker compose ps
   ```

   Deberías ver el servicio `juice-shop` con estado `running` (healthy).

2. Abre la aplicación en tu navegador:

   <http://localhost:3000>

3. Si todo funciona correctamente, verás la página principal de
   **OWASP Juice Shop**.

---

## Escaneo DAST con OWASP ZAP

El laboratorio incluye un servicio `zap` en `docker-compose.yml` bajo el
perfil `scan`. Se ejecuta bajo demanda y no arranca con `docker compose up`.

Ejecutar un escaneo **baseline** (rápido, pasivo):

```bash
./scripts/scan.sh
# o
docker compose --profile scan run --rm zap
```

Ejecutar un **full scan** (activo, tarda más):

```bash
./scripts/scan.sh full
```

En Windows (PowerShell):

```powershell
./scripts/scan.ps1
./scripts/scan.ps1 full
```

Los reportes se generan en [`reports/`](reports/) en formatos HTML, JSON y
Markdown. Las reglas personalizadas viven en [`zap/rules.tsv`](zap/rules.tsv).

---

## DAST en GitHub Actions

El repositorio incluye el workflow [`dast`](.github/workflows/dast.yml) que
ejecuta un escaneo automatizado con OWASP ZAP en la nube.

### Triggers

| Evento                        | Acción                                             |
| ----------------------------- | -------------------------------------------------- |
| `workflow_dispatch`           | Ejecución manual (elegir `target` y `scan_type`).  |
| `pull_request` sobre `main`   | Cambios en `docker-compose.yml`, `zap/**`, `app-vulnerable-api/**` o el workflow. |
| `schedule` (lunes 06:00 UTC)  | Escaneo semanal automatizado (ambas apps).         |

### Estrategia matrix

El workflow usa `strategy.matrix` para escanear las dos apps en paralelo:

| Job                       | Target                              | Artifact                              |
| ------------------------- | ----------------------------------- | ------------------------------------- |
| `ZAP juice-shop`          | `http://localhost:3000` (imagen)    | `zap-<baseline\|full>-juice-shop`     |
| `ZAP vulnerable-api`      | `http://localhost:4000` (build)     | `zap-<baseline\|full>-vulnerable-api` |

### Ejecución manual

Desde la pestaña **Actions** del repositorio:

1. Selecciona el workflow **dast**.
2. `Run workflow` → elige:
   - **target**: `all` (default), `juice-shop` o `vulnerable-api`.
   - **scan_type**: `baseline` (default) o `full`.
3. Al finalizar, descarga los reportes desde la sección **Artifacts** del run.

---

## Remediación con GitHub Copilot

El laboratorio cubre **dos enfoques complementarios** de remediación DAST
con Copilot:

| Enfoque | Cuándo aplica                                | App demo                        | Fix        | Guía |
| ------- | --------------------------------------------- | ------------------------------- | ---------- | ----- |
| **A**   | No tenemos el código (SaaS, imagen de 3ros)   | OWASP Juice Shop (`:3000`)      | Reverse proxy Caddy con security headers | [docs/Remediation.md](docs/Remediation.md) |
| **B**   | Tenemos el código (app propia)               | `vulnerable-api` (`:4000`)      | Refactor con `execFile`, prepared stmts, escape HTML, `path.resolve` | [docs/RemediationCode.md](docs/RemediationCode.md) |

Uso rápido del enfoque A:

```bash
# Levantar el reverse proxy endurecido
docker compose --profile hardened up -d proxy

# Escanear contra el proxy en lugar de la app directa
./scripts/scan.sh baseline http://proxy:8080
```

Resultado medido: `WARN-NEW` **7 → 4**, `PASS` **59 → 62**.

Uso rápido del enfoque B:

```bash
# La app queda accesible en http://localhost:4000
docker compose up -d vulnerable-api

# Explotar la SQLi (antes del fix)
curl -sG "http://localhost:4000/users/search" --data-urlencode "name=' OR '1'='1"
```

Luego seguir el guión por vulnerabilidad de
[docs/RemediationCode.md](docs/RemediationCode.md).

---

## Limpieza

Detener los contenedores manteniendo los datos:

```bash
docker compose stop
```

Detener y eliminar los contenedores, redes y volúmenes creados:

```bash
docker compose down -v
```

También puedes usar los scripts incluidos:

- **macOS / Linux:** `./scripts/stop.sh` o `./scripts/cleanup.sh`
- **Windows (PowerShell):** `./scripts/stop.ps1` o `./scripts/cleanup.ps1`

---

## Estructura del repositorio

```text
copilot-dast-workshop/
├── README.md              # Este archivo
├── LICENSE                # Licencia del laboratorio
├── .gitignore             # Reglas de exclusión de Git
├── docker-compose.yml     # Definición de servicios (Juice Shop)
├── app/                   # Espacio reservado para código de la app
├── docs/                  # Documentación del workshop
├── reports/               # Reportes generados (etapas posteriores)
├── scripts/               # Scripts de arranque, parada y limpieza
├── zap/                   # Configuración de OWASP ZAP (etapas posteriores)
└── .github/
    └── workflows/         # Workflows de GitHub Actions
```

---

## Próximos pasos

En las siguientes etapas del workshop se agregará:

- Integración con **OWASP ZAP** para escaneos DAST.
- **GitHub Actions** para automatización del pipeline DevSecOps.
- Generación de **reportes** de seguridad.
- Ejercicios de **remediación asistida por GitHub Copilot**.

---

## Licencia

Distribuido bajo la licencia MIT. Consulta [LICENSE](LICENSE) para más detalles.
