// [FIXED] Command Injection remediado.
// Refactorizado en el workshop (Paso 3.3) con ayuda de GitHub Copilot Chat.
//
// Cambios aplicados:
//  - `child_process.execFile` en lugar de `exec`: se pasa argv como array,
//    sin invocar shell, por lo que `;`, `|`, `&&`, `$(...)` dejan de ser
//    interpretados. El caracter `;` viaja tal cual como parte de un
//    argumento, y `ping` lo rechaza como hostname invalido.
//  - Regex conservador HOST_RE para validar el input antes de ejecutar:
//    solo letras, digitos, puntos y guiones; maximo 253 caracteres
//    (limite RFC 1035 para un FQDN).
//  - 400 Bad Request "invalid host" si el regex no matchea.
//  - Timeout de 3 segundos preservado (option `timeout` de execFile).
//  - En error 500 solo se devuelve un mensaje generico "ping failed" —
//    ya no se filtra stderr ni err.message que pueden revelar rutas,
//    versiones o topologia de red.

const { Router } = require('express');
const { execFile } = require('child_process');

const router = Router();

// Letras, digitos, puntos y guiones; entre 1 y 253 caracteres.
// Cubre IPv4 (127.0.0.1) y hostnames simples (example.com, my-host-01).
// NO acepta IPv6 (:), rutas, espacios ni metacaracteres de shell.
const HOST_RE = /^[a-zA-Z0-9.-]{1,253}$/;

router.get('/', (req, res) => {
  const host = typeof req.query.host === 'string' ? req.query.host : '127.0.0.1';

  if (!HOST_RE.test(host)) {
    return res.status(400).type('text/plain').send('invalid host');
  }

  execFile(
    'ping',
    ['-c', '1', '-W', '1', host],
    { timeout: 3000 },
    (err, stdout /*, stderr */) => {
      if (err) {
        // No filtrar stderr ni err.message para no revelar detalles del sistema.
        return res.status(500).type('text/plain').send('ping failed');
      }
      res.type('text/plain').send(stdout);
    }
  );
});

module.exports = router;
