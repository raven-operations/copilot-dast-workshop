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

## Paso 7 - Detener el laboratorio

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
