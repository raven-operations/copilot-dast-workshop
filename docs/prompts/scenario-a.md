# Cheat sheet de prompts — Escenario A (Juice Shop, sin acceso al código)

> Prompts listos para copiar/pegar en Copilot Chat. El contexto completo
> (por qué, qué esperar, cómo verificar) está en
> [`docs/Remediation.md`](../Remediation.md).

**App target:** OWASP Juice Shop (`http://localhost:3000`)
**Estrategia:** reverse proxy Caddy en `http://localhost:8080` con
security headers.

---

## Prompt 1 — Interpretar el reporte

> Abrí el archivo del reporte en el editor antes de pegar el prompt:
> `reports/zap-baseline-juice-shop_3000.md`.

```text
Analiza este reporte de OWASP ZAP y genera una tabla en Markdown con
las 5 vulnerabilidades más importantes. Para cada una incluye:
ID de regla, título, severidad, resumen en una línea, y qué header
HTTP o configuración las remediaría.
```

---

## Prompt 2 — Generar el Caddyfile

```text
Genera un Caddyfile para Caddy 2 que actúe como reverse proxy delante
de http://juice-shop:3000, escuche en el puerto 8080 y añada los
siguientes headers de seguridad de respuesta:

- Content-Security-Policy (compatible con una SPA Angular que usa
  inline styles y JIT)
- Cross-Origin-Embedder-Policy: credentialless
- Cross-Origin-Opener-Policy: same-origin
- Cross-Origin-Resource-Policy: same-origin
- Permissions-Policy con geolocation, microphone, camera, payment,
  usb, interest-cohort deshabilitados
- Referrer-Policy: strict-origin-when-cross-origin
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- Strict-Transport-Security: max-age=31536000; includeSubDomains
- Cache-Control: no-store

También elimina los headers Server, X-Powered-By, Feature-Policy
y Access-Control-Allow-Origin que vienen del upstream. Desactiva
HTTPS automático y la API admin de Caddy.
```

**Resultado esperado:** algo equivalente a [`proxy/Caddyfile`](../../proxy/Caddyfile).

---

## Prompt 3 — Agregar el servicio al Docker Compose

```text
Agrega un servicio llamado proxy a mi docker-compose.yml usando la
imagen caddy:2.11.4-alpine. Requisitos:

- Debe estar bajo el perfil hardened (no arranca por defecto).
- Depende de juice-shop con condition: service_healthy.
- Monta ./proxy/Caddyfile como /etc/caddy/Caddyfile en modo solo
  lectura.
- Expone el puerto 8080:8080.
- Se conecta a la red dast-lab.
- container_name: proxy.
```

**Resultado esperado:** bloque `proxy:` en [`docker-compose.yml`](../../docker-compose.yml).

---

## Prompt 4 — Re-escanear el target endurecido

```text
Extiende scripts/scan.sh para que acepte un segundo argumento opcional
con el target (default http://juice-shop:3000). Si el target contiene
la palabra "proxy", levanta también el servicio proxy con el perfil
hardened. Genera reportes cuyo nombre incluya un slug del target
(ej. zap-baseline-proxy_8080.md).
```

**Resultado esperado:** [`scripts/scan.sh`](../../scripts/scan.sh).

---

## Prompts opcionales (avanzados)

### Prompt 5 — Diagnóstico funcional del CSP

```text
Abrí http://localhost:8080 en el navegador y en la consola veo estos
errores CSP: [PEGAR ERRORES]. Ajusta la directiva Content-Security-Policy
del Caddyfile para permitirlos manteniendo la política lo más
restrictiva posible.
```

### Prompt 6 — Migrar los headers a la app (hipotético)

```text
Suponiendo que Juice Shop fuera nuestro código (Express + Angular),
genera un middleware Express que aplique exactamente los mismos
headers que hoy inyecta el Caddyfile. Usa helmet como base.
```

### Prompt 7 — Endurecer la política CSP

```text
Revisa el Caddyfile y sugiere una versión más estricta del CSP
que reemplace 'unsafe-inline' y 'unsafe-eval' por hashes o
nonces. Explica qué cambios haría falta en el frontend Angular.
```

---

## Comandos de verificación

```bash
# Baseline directo contra Juice Shop
./scripts/scan.sh baseline

# Levantar el proxy endurecido
docker compose --profile hardened up -d proxy

# Baseline contra el proxy
./scripts/scan.sh baseline http://proxy:8080
```

Comparar `reports/zap-baseline-juice-shop_3000.md` vs
`reports/zap-baseline-proxy_8080.md`.

**Métrica objetivo:** `WARN-NEW` **7 → 4**, `PASS` **59 → 62**.
