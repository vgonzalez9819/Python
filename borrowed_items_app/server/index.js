const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Database setup
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
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simple login endpoint
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  db.get('SELECT * FROM users WHERE username = ? AND password = ?', [username, password], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(401).json({ error: 'Invalid credentials' });
    res.json({ id: row.id, username: row.username });
  });
});

// Fetch items for a user
app.get('/api/items/:userId', (req, res) => {
  const { userId } = req.params;
  db.all('SELECT * FROM items WHERE borrowed_by = ?', [userId], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Mark item as returned
app.post('/api/items/:itemId/return', (req, res) => {
  const { itemId } = req.params;
  db.run('UPDATE items SET returned = 1 WHERE id = ?', [itemId], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true });
  });
});

// Admin report
app.get('/api/admin/report', (req, res) => {
  db.all('SELECT * FROM items', (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
