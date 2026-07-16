// [FIXED] Path Traversal remediado.
// Refactorizado en el workshop (Paso 3.4) con ayuda de GitHub Copilot Chat.
//
// Defensa en profundidad en 3 capas:
//  1) Blacklist explicita: rechazar cualquier `name` que contenga `/`, `\`
//     o `..` antes de tocar el filesystem (fail-fast, mensaje claro).
//  2) `path.resolve` en vez de `path.join`: normaliza la ruta a un
//     absolute path que se puede comparar contra el BASE_DIR.
//  3) Verificacion de prefijo: la ruta resuelta DEBE empezar con
//     `BASE_DIR + path.sep`. Esto captura ataques que hayan pasado
//     la blacklist (ej. codepoints unicode raros, symlinks, etc.).
//
// Ademas: 404 generico ("not found") sin filtrar `err.code` ni la ruta
// intentada, para no revelar la estructura del filesystem del contenedor.

const { Router } = require('express');
const fs = require('fs');
const path = require('path');

const router = Router();
const BASE_DIR = path.resolve(__dirname, '..', '..', 'files');

router.get('/', (req, res) => {
  const name = typeof req.query.name === 'string' ? req.query.name : 'hello.txt';

  // Capa 1: rechazar separadores de ruta y ".." antes de siquiera resolver.
  if (name.includes('/') || name.includes('\\') || name.includes('..')) {
    return res.status(400).type('text/plain').send('invalid name');
  }

  // Capa 2: resolver a un absolute path canonico.
  const filePath = path.resolve(BASE_DIR, name);

  // Capa 3: verificar que la ruta resuelta este dentro de BASE_DIR.
  // El path.sep evita falsos positivos si hay un directorio hermano
  // cuyo nombre empieza con el mismo prefijo que BASE_DIR.
  if (!filePath.startsWith(BASE_DIR + path.sep)) {
    return res.status(400).type('text/plain').send('invalid name');
  }

  fs.readFile(filePath, 'utf-8', (err, data) => {
    if (err) {
      // No filtrar err.code ni la ruta intentada.
      return res.status(404).type('text/plain').send('not found');
    }
    res.type('text/plain').send(data);
  });
});

module.exports = router;
