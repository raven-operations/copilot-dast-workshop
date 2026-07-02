// [VULNERABLE] Reflected XSS.
// Devuelve HTML embebiendo el parámetro sin escapar.
// Ejemplo de explotación:
//   curl "http://localhost:4000/greet?name=<script>alert(1)</script>"

const { Router } = require('express');

const router = Router();

router.get('/', (req, res) => {
  const name = req.query.name || 'stranger';
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
