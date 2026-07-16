// [FIXED] Reflected XSS remediado con escape de entidades HTML.
// Refactorizado en el workshop (Paso 3.2) con ayuda de GitHub Copilot Chat.
// El parametro `name` ahora se escapa antes de interpolarlo en el template,
// asi payloads como `<script>alert(1)</script>` quedan neutralizados como
// `&lt;script&gt;alert(1)&lt;/script&gt;` (texto plano, no ejecutable).
//
// Cambios aplicados:
//  - Funcion `escapeHtml` local (sin dependencias externas) que codifica
//    los 5 caracteres criticos: & < > " '
//  - Validacion previa: 400 Bad Request si `name` excede 50 caracteres.
//  - Se sanea tambien el default 'stranger' via la misma funcion por
//    consistencia (aunque es un literal seguro).

const { Router } = require('express');

const router = Router();

const NAME_MAX_LENGTH = 50;

/**
 * Escapa las 5 entidades HTML criticas para prevenir XSS al interpolar
 * texto controlado por el usuario dentro de un documento HTML.
 * NOTA: & tiene que ir primero para no doble-escapar los `&` introducidos
 * por los otros reemplazos.
 */
function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

router.get('/', (req, res) => {
  const raw = typeof req.query.name === 'string' ? req.query.name : 'stranger';

  if (raw.length > NAME_MAX_LENGTH) {
    return res
      .status(400)
      .type('text/plain')
      .send(`name exceeds ${NAME_MAX_LENGTH} characters`);
  }

  const name = escapeHtml(raw);
  const html = `<!DOCTYPE html>
<html>
  <head><title>Greeter</title></head>
  <body>
    <h1>Hello, ${name}!</h1>
    <p>Welcome to the vulnerable-api.</p>
  </body>
</html>`;
  res.type('html').send(html);
});

module.exports = router;
