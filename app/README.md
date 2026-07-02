# app/

Contiene el código fuente de las aplicaciones del laboratorio que **sí son
nuestras** (es decir, cuyo código podemos modificar).

- [`vulnerable-api/`](vulnerable-api/) — API Node.js/Express con
  vulnerabilidades intencionales (SQLi, XSS, Command Injection,
  Path Traversal). Usada en el módulo de **remediación en código con
  Copilot** ([`../docs/RemediationCode.md`](../docs/RemediationCode.md)).

> OWASP Juice Shop **no** vive aquí porque usamos su imagen oficial de
> Docker Hub (`bkimminich/juice-shop`) directamente. Es el ejemplo del
> caso "no tengo el código fuente".
