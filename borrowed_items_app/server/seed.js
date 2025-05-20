const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, 'database.db'));

db.serialize(() => {
  db.run("INSERT INTO users (username, password) VALUES ('student1', 'password')");
  db.run("INSERT INTO items (name, borrowed_by) VALUES ('Laptop', 1)");
  db.run("INSERT INTO items (name, borrowed_by) VALUES ('Charger', 1)");
  db.run("INSERT INTO items (name, borrowed_by) VALUES ('Yonder pouch', 1)");
});

db.close();
