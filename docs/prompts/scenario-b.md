# Cheat sheet de prompts — Escenario B (vulnerable-api, con acceso al código)

> Prompts listos para copiar/pegar en Copilot Chat. El contexto
> completo (código vulnerable, código esperado, curl de verificación,
> puntos didácticos) está en
> [`docs/RemediationCode.md`](../RemediationCode.md).

**App target:** `vulnerable-api` (`http://localhost:4000`)
**Estrategia:** refactor del código Express con Copilot; rebuild del
contenedor tras cada fix.

---

## Tabla resumen

| # | Vulnerabilidad     | Endpoint            | Archivo                                                             |
| - | ------------------ | ------------------- | ------------------------------------------------------------------- |
| 1 | SQL Injection      | `GET /users/search` | [`src/routes/users.js`](../../app-vulnerable-api/src/routes/users.js) |
| 2 | Reflected XSS      | `GET /greet`        | [`src/routes/greet.js`](../../app-vulnerable-api/src/routes/greet.js) |
| 3 | Command Injection  | `GET /ping`         | [`src/routes/ping.js`](../../app-vulnerable-api/src/routes/ping.js)   |
| 4 | Path Traversal     | `GET /files`        | [`src/routes/files.js`](../../app-vulnerable-api/src/routes/files.js) |

---

## 1. SQL Injection — `GET /users/search`

### Explotación

```bash
curl -sG "http://localhost:4000/users/search" \
     --data-urlencode "name=' OR '1'='1"
```

### Prompt para Copilot Chat

```text
El archivo app-vulnerable-api/src/routes/users.js es vulnerable a
SQL Injection porque concatena el parámetro name directamente en
la query. Refactorízalo para usar prepared statements con parámetros
ligados (better-sqlite3 soporta ?). Mantén la búsqueda por
substring (LIKE %...%). No devuelvas la query cruda en la respuesta.
```

### Verificación

```bash
docker compose up -d --build vulnerable-api
curl -sG "http://localhost:4000/users/search" --data-urlencode "name=' OR '1'='1"
# → {"results":[]}
```

---

## 2. Reflected XSS — `GET /greet`

### Explotación

```bash
curl -sG "http://localhost:4000/greet" \
     --data-urlencode "name=<script>alert(1)</script>"
```

### Prompt para Copilot Chat

```text
app-vulnerable-api/src/routes/greet.js sufre Reflected XSS
porque interpola name en HTML sin escapar. Refactorízalo para
escapar entidades HTML (<, >, ", ', &). No uses librerías
externas si podemos evitarlo — implementá una función escapeHtml
pequeña y aplicala al parámetro antes de renderizar.
```

### Verificación

```bash
docker compose up -d --build vulnerable-api
curl -sG "http://localhost:4000/greet" --data-urlencode "name=<script>alert(1)</script>" | grep -c '<script>'
# → 0
```

---

## 3. Command Injection — `GET /ping`

### Explotación

```bash
curl -sG "http://localhost:4000/ping" --data-urlencode "host=127.0.0.1;id"
```

### Prompt para Copilot Chat

```text
app-vulnerable-api/src/routes/ping.js es vulnerable a Command
Injection porque interpola host en un string ejecutado por shell.
Refactorízalo para:

1. Usar child_process.execFile (sin shell) en lugar de exec.
2. Validar que host cumpla un regex conservador (letras, dígitos,
   puntos y guiones; máximo 253 caracteres). Rechazar con 400 Bad
   Request si no.
3. Mantener el timeout de 3 segundos.
```

### Verificación

```bash
docker compose up -d --build vulnerable-api
curl -sG "http://localhost:4000/ping" --data-urlencode "host=127.0.0.1;id"
# → invalid host
```

---

## 4. Path Traversal — `GET /files`

### Explotación

```bash
curl -sG "http://localhost:4000/files" \
     --data-urlencode "name=../../../../etc/passwd"
```

### Prompt para Copilot Chat

```text
app-vulnerable-api/src/routes/files.js es vulnerable a Path
Traversal. Refactorízalo para:

1. Resolver la ruta final con path.resolve(BASE_DIR, name).
2. Verificar que la ruta resuelta empiece con BASE_DIR + path.sep.
3. Rechazar con 400 si el nombre contiene separadores de ruta o ..
4. Devolver 404 cuando el archivo no exista, sin filtrar detalles
   del filesystem.
```

### Verificación

```bash
docker compose up -d --build vulnerable-api
curl -sG "http://localhost:4000/files" --data-urlencode "name=../../../../etc/passwd"
# → invalid name
curl -sG "http://localhost:4000/files" --data-urlencode "name=hello.txt"
# → Hello from vulnerable-api!
```

---

## Verificación integral con OWASP ZAP

El **baseline** (pasivo) no detecta SQLi/XSS/cmd-injection porque no
envía payloads. Para ver la reducción real de findings hay que correr
un **full scan** (activo):

```bash
./scripts/scan.sh full http://vulnerable-api:4000
```

Comparar el reporte antes vs después del refactor con Copilot.
