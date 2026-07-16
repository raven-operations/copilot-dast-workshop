// [FIXED] SQL Injection remediado con prepared statements.
// Refactorizado en el workshop (Paso 3.1) con ayuda de GitHub Copilot Chat.
// El parametro `name` se liga con `?` en vez de concatenarse en la query,
// por lo que el payload `' OR '1'='1` deja de bypassear el filtro.
//
// Cambios aplicados:
//  - Prepared statement con better-sqlite3 (`?` binding).
//  - Se mantiene la busqueda por substring con `LIKE ?` + `%...%`.
//  - Ya no se devuelve la query cruda en la respuesta (evita info disclosure).
//  - 400 Bad Request si `name` excede 100 caracteres (defensa en profundidad).

const { Router } = require('express');
const { db } = require('../db');

const router = Router();

const NAME_MAX_LENGTH = 100;

router.get('/search', (req, res) => {
  const name = typeof req.query.name === 'string' ? req.query.name : '';

  if (name.length > NAME_MAX_LENGTH) {
    return res
      .status(400)
      .json({ error: `name exceeds ${NAME_MAX_LENGTH} characters` });
  }

  try {
    const stmt = db.prepare(
      'SELECT id, name, email FROM users WHERE name LIKE ?'
    );
    const rows = stmt.all(`%${name}%`);
    res.json({ results: rows });
  } catch (err) {
    // No filtrar detalles internos (mensaje de err ni query).
    res.status(500).json({ error: 'internal error' });
  }
});

module.exports = router;
