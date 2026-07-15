# vulnerable-api

> Aplicación Node.js/Express **intencionalmente vulnerable** creada para el
> workshop **Copilot para Vulnerabilidades de Seguridad DAST con ZAP Proxy**.

## Objetivo pedagógico

A diferencia de OWASP Juice Shop (imagen de terceros que no podemos
modificar), esta app existe para demostrar el **enfoque directo de
remediación**: cuando el código **sí es tuyo**, Copilot Chat te ayuda a
arreglar la raíz del problema.

Cada endpoint contiene UNA vulnerabilidad canónica del OWASP Top 10.

## Endpoints

| Método | Path                    | Vulnerabilidad         | OWASP Top 10 |
| ------ | ----------------------- | ---------------------- | ------------ |
| GET    | `/users/search?name=`   | SQL Injection          | A03:2021     |
| GET    | `/greet?name=`          | Reflected XSS          | A03:2021     |
| GET    | `/ping?host=`           | Command Injection      | A03:2021     |
| GET    | `/files?name=`          | Path Traversal         | A01:2021     |

Ver el [README.md principal — Paso 3](../README.md#-paso-3-remediar-vulnerabilidades-en-código-con-copilot)
para el guion de remediación paso a paso con Copilot Chat.

## Ejecución

Levantada automáticamente por `docker compose up -d`. Accesible en:
<http://localhost:4000>.

## Advertencia

**NO exponer esta aplicación fuera del laboratorio local.** El puerto 4000
solo debería estar accesible desde `localhost` durante el workshop.
