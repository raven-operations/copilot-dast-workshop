# GitHub Copilot + OWASP ZAP (DAST) Workshop

[![validate](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/validate.yml/badge.svg)](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/validate.yml)
[![dast-juice-shop](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast-juice-shop.yml/badge.svg)](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast-juice-shop.yml)
[![dast-vulnerable-api](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast-vulnerable-api.yml/badge.svg)](https://github.com/clever-devops-tools/copilot-dast-workshop/actions/workflows/dast-vulnerable-api.yml)

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

El laboratorio contiene **dos escenarios** independientes con la misma
orquestación de Docker Compose. Cada uno enseña un enfoque distinto de
remediación asistida por Copilot.

### Escenario A — Juice Shop (sin acceso al código)

Target de terceros; la remediación se hace **desde afuera** con un
reverse proxy Caddy que inyecta headers de seguridad.

```mermaid
flowchart LR
    Dev["Participante<br>VS Code + Copilot"]
    Compose["Docker Compose"]
    Juice["OWASP Juice Shop<br>:3000"]
    Proxy["Caddy Reverse Proxy<br>:8080 · profile hardened"]
    Browser["Navegador"]
    ZAP["OWASP ZAP<br>profile scan"]
    Reports[("reports/")]

    Dev -->|docker compose up| Compose
    Compose --> Juice
    Compose -.->|profile hardened| Proxy
    Proxy --> Juice
    Browser --> Juice
    Browser -.-> Proxy
    ZAP -->|baseline / full| Juice
    ZAP -.->|baseline / full| Proxy
    ZAP -->|HTML · JSON · MD| Reports
```

Flujo típico: escaneo → hallazgos de headers → Copilot Chat genera el
`Caddyfile` → segundo escaneo contra `:8080` → hallazgos reducidos.

### Escenario B — Vulnerable API (con acceso al código)

App propia con vulnerabilidades incrustadas (SQLi, XSS, CmdInjection,
PathTraversal). La remediación se hace **en el código fuente** y se
rebuildea el contenedor.

```mermaid
flowchart LR
    Dev["Participante<br>VS Code + Copilot"]
    Compose["Docker Compose"]
    Src["app-vulnerable-api/src/<br>Express + SQLite"]
    API["vulnerable-api<br>:4000"]
    Curl["curl / navegador"]
    ZAP["OWASP ZAP<br>profile scan"]
    Reports[("reports/")]

    Dev -->|edita con Copilot| Src
    Src -->|build| API
    Dev -->|docker compose up --build| Compose
    Compose --> API
    Curl --> API
    ZAP -->|baseline / full| API
    ZAP -->|HTML · JSON · MD| Reports
```

Flujo típico: exploit con `curl` → Copilot Chat refactoriza la ruta
vulnerable → `docker compose up -d --build vulnerable-api` → exploit
falla → escaneo confirma.

### Componentes comunes

| Componente        | Rol                                                        |
| ----------------- | ---------------------------------------------------------- |
| Docker Compose    | Orquesta todos los servicios del laboratorio.              |
| OWASP ZAP         | Escáner DAST (baseline / full); perfil `scan` on-demand.   |
| GitHub Actions    | Workflow `dast` que corre ambos escenarios en CI (matrix). |

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

El repositorio incluye **un workflow por aplicación** para que cada uno
tenga su propio badge de estado, más un workflow reutilizable con la
lógica compartida.

| Workflow                                                                                | Rol                                                    |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| [`dast-juice-shop`](.github/workflows/dast-juice-shop.yml)                              | Escanea OWASP Juice Shop.                              |
| [`dast-vulnerable-api`](.github/workflows/dast-vulnerable-api.yml)                      | Escanea la `vulnerable-api`.                           |
| [`_dast-reusable`](.github/workflows/_dast-reusable.yml)                                | Lógica compartida (`workflow_call`); no se lanza sola. |

### Triggers

Ambos wrappers usan el mismo esquema:

| Evento                        | Acción                                                     |
| ----------------------------- | ---------------------------------------------------------- |
| `workflow_dispatch`           | Ejecución manual (elegir `scan_type`: baseline o full).    |
| `pull_request` sobre `main`   | Cambios en `docker-compose.yml`, `zap/**`, sus paths propios o el reusable. |
| `schedule` (lunes 06:00 UTC)  | Escaneo semanal automatizado.                              |

### Ejecución manual

Desde la pestaña **Actions** del repositorio:

1. Selecciona **dast-juice-shop** o **dast-vulnerable-api**.
2. `Run workflow` → elige `scan_type` (`baseline` o `full`).
3. Al finalizar, descarga los reportes desde la sección **Artifacts** del run
   (`zap-<scan_type>-<target>`).

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
