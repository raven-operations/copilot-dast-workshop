// SQLite en memoria con usuarios de ejemplo.

const Database = require('better-sqlite3');
const db = new Database(':memory:');

function initDb() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id       INTEGER PRIMARY KEY AUTOINCREMENT,
      name     TEXT NOT NULL,
      email    TEXT NOT NULL,
      is_admin INTEGER NOT NULL DEFAULT 0
    );
  `);

  const count = db.prepare('SELECT COUNT(*) AS c FROM users').get().c;
  if (count === 0) {
    const insert = db.prepare(
      'INSERT INTO users (name, email, is_admin) VALUES (?, ?, ?)'
    );
    insert.run('alice', 'alice@example.com', 0);
    insert.run('bob',   'bob@example.com',   0);
    insert.run('carol', 'carol@example.com', 0);
    insert.run('admin', 'admin@example.com', 1);
  }
}

module.exports = { db, initDb };
