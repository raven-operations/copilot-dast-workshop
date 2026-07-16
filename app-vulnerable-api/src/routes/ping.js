// [VULNERABLE] Command Injection.
// Concatena el parámetro `host` dentro de un comando shell.
// Ejemplo de explotación:
//   curl "http://localhost:4000/ping?host=127.0.0.1;id"
//   curl "http://localhost:4000/ping?host=127.0.0.1%20%7C%7C%20cat%20/etc/passwd"

const { Router } = require('express');
const { exec } = require('child_process');

const router = Router();

router.get('/', (req, res) => {
  const host = req.query.host || '127.0.0.1';
  const cmd = `ping -c 1 -W 1 ${host}`;
  exec(cmd, { timeout: 3000 }, (err, stdout, stderr) => {
    if (err) {
      return res.status(500).type('text/plain').send(`${stderr}\n${err.message}`);
    }
    res.type('text/plain').send(stdout);
  });
});

module.exports = router;
