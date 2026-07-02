// [VULNERABLE] SQL Injection.
// Concatena directamente el parámetro `name` dentro de la query SQL.
// Ejemplo de explotación:
//   curl "http://localhost:4000/users/search?name=' OR '1'='1"

const { Router } = require('express');
const { db } = require('../db');

const router = Router();

router.get('/search', (req, res) => {
  const name = req.query.name || '';
  const sql = `SELECT id, name, email FROM users WHERE name LIKE '%${name}%'`;
  try {
    const rows = db.prepare(sql).all();
    res.json({ query: sql, results: rows });
  } catch (err) {
    res.status(500).json({ error: err.message, query: sql });
  }
});

module.exports = router;
