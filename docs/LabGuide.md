# Guia del laboratorio (Lab Guide)

> Guia paso a paso para completar la **etapa 1** del laboratorio.

## Prerrequisitos

- Docker Desktop en ejecucion.
- Git instalado.
- Visual Studio Code con GitHub Copilot habilitado.

## Paso 1 - Clonar el repositorio

```bash
git clone https://github.com/clever-devops-tools/copilot-dast-workshop.git
cd copilot-dast-workshop
```

## Paso 2 - Abrir el proyecto en VS Code

```bash
code .
```

Verifica que Copilot este activo (icono en la barra inferior).

## Paso 3 - Levantar la aplicacion vulnerable

```bash
docker compose up -d
```

O bien:

- macOS / Linux: `./scripts/start.sh`
- Windows: `./scripts/start.ps1`

## Paso 4 - Verificar el estado

```bash
docker compose ps
```

El servicio `juice-shop` debe aparecer como `running` (healthy).

## Paso 5 - Acceder a la aplicacion

Abre en el navegador:

<http://localhost:3000>

Deberias ver la pagina principal de OWASP Juice Shop.

## Paso 6 - Explorar la aplicacion

Navega libremente. Esta aplicacion sera el objetivo de los escaneos DAST
en la etapa 2 del workshop.

## Paso 7 - Ejecutar un escaneo DAST con OWASP ZAP

El laboratorio incluye un servicio `zap` en `docker-compose.yml` bajo el
perfil `scan`, de forma que no se levanta durante `docker compose up -d` y
solo corre bajo demanda.

### Opcion A - Script

- macOS / Linux:

  ```bash
  ./scripts/scan.sh              # baseline (rapido, pasivo, ~2 min)
  ./scripts/scan.sh full         # full scan (activo, 10-30 min)
  ```

- Windows (PowerShell):

  ```powershell
  ./scripts/scan.ps1
  ./scripts/scan.ps1 full
  ```

### Opcion B - Docker Compose directo

```bash
docker compose --profile scan run --rm zap
```

### Revisar los reportes

Los reportes se generan en `reports/`:

| Archivo                          | Formato       | Uso sugerido                          |
| -------------------------------- | ------------- | ------------------------------------- |
| `zap-baseline-report.html`       | HTML          | Abrir en el navegador para revisar.   |
| `zap-baseline-report.json`       | JSON          | Ingesta por herramientas / scripts.   |
| `zap-baseline-report.md`         | Markdown      | Compartir en PRs o documentacion.     |

Abrir el HTML en macOS:

```bash
open reports/zap-baseline-report.html
```

### Personalizar reglas

El archivo [`zap/rules.tsv`](../zap/rules.tsv) permite marcar reglas como
`IGNORE`, `WARN` o `FAIL`. Se monta como `/zap/config/rules.tsv` dentro
del contenedor.

## Paso 8 - Detener el laboratorio

Detener manteniendo contenedores:

```bash
docker compose stop
```

Eliminar todo lo creado:

```bash
docker compose down -v
```

O usa los scripts `stop.*` y `cleanup.*` incluidos en `scripts/`.

## Troubleshooting

| Problema                              | Posible causa / solucion                                  |
| ------------------------------------- | --------------------------------------------------------- |
| El puerto 3000 esta ocupado           | Detener el proceso que lo usa o cambiar el mapeo.         |
| `docker compose` no encontrado        | Actualizar Docker Desktop (requiere Compose v2).          |
| El contenedor no arranca              | Revisar logs: `docker compose logs juice-shop`.           |
