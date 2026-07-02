# GitHub Copilot + OWASP ZAP (DAST) Workshop

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
