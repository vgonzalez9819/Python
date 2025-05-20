const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, 'database.db'));

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
  )`);
  db.run(`CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    borrowed_by INTEGER,
    returned INTEGER DEFAULT 0,
    FOREIGN KEY(borrowed_by) REFERENCES users(id)
  )`);

  db.run("INSERT OR IGNORE INTO users (id, username, password) VALUES (1, 'student', 'password')");
  db.run("INSERT OR IGNORE INTO items (name, borrowed_by, returned) VALUES ('Laptop', 1, 0)");
  db.run("INSERT OR IGNORE INTO items (name, borrowed_by, returned) VALUES ('Charger', 1, 0)");
  db.run("INSERT OR IGNORE INTO items (name, borrowed_by, returned) VALUES ('Yonder Pouch', 1, 0)");
});

db.close(() => console.log('Database seeded.'));
