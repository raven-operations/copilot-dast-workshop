// [VULNERABLE] Path Traversal.
// path.join permite que ".." escape del directorio base `files/`.
// Ejemplo de explotación:
//   curl "http://localhost:4000/files?name=../../../../etc/passwd"

const { Router } = require('express');
const fs = require('fs');
const path = require('path');

const router = Router();
const BASE_DIR = path.join(__dirname, '..', '..', 'files');

router.get('/', (req, res) => {
  const name = req.query.name || 'hello.txt';
  const filePath = path.join(BASE_DIR, name);
  fs.readFile(filePath, 'utf-8', (err, data) => {
    if (err) {
      return res.status(404).type('text/plain').send('Not found');
    }
    res.type('text/plain').send(data);
  });
});

module.exports = router;
