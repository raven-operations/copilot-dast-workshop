// vulnerable-api - punto de entrada.
// Cada ruta expone UNA vulnerabilidad canónica del OWASP Top 10 para
// que el workshop la remedie con ayuda de Copilot Chat.
//
// NO USAR EN PRODUCCIÓN.

const express = require('express');
const { initDb } = require('./db');

const app = express();
app.use(express.json());

app.get('/', (_req, res) => {
  res.type('text/plain').send(
    [
      'vulnerable-api (workshop)',
      '',
      'Endpoints intencionalmente vulnerables:',
      '  GET /health              - liveness check',
      '  GET /users/search?name=  - SQL Injection',
      '  GET /greet?name=         - Reflected XSS',
      '  GET /ping?host=          - Command Injection',
      '  GET /files?name=         - Path Traversal',
    ].join('\n')
  );
});

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/users', require('./routes/users'));
app.use('/greet', require('./routes/greet'));
app.use('/ping', require('./routes/ping'));
app.use('/files', require('./routes/files'));

const PORT = process.env.PORT || 4000;

initDb();
app.listen(PORT, () => {
  console.log(`[vulnerable-api] listening on ${PORT}`);
});
