# Reportes

Carpeta de salida de OWASP ZAP. Cada corrida de
[`scripts/scan.sh`](../scripts/scan.sh) genera aquí tres archivos
(`.html`, `.json`, `.md`) con el nombre
`zap-<baseline|full>-<target_slug>.*`.

El contenido está excluido en `.gitignore` (solo este README y
`.gitkeep` se versionan) para que cada participante genere sus propios
reportes al reproducir el laboratorio.