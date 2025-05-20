const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, 'database.db'));

db.serialize(() => {
  db.run('DELETE FROM users');
  db.run('DELETE FROM items');

  db.run('INSERT INTO users (username, password) VALUES ("alice", "password"), ("bob", "password")');

  db.run('INSERT INTO items (name, borrowed_by, returned) VALUES ' +
    '("Laptop", 1, 0),' +
    '("Charger", 1, 0),' +
    '("Yonder Pouch", 2, 0)');
});

db.close();
