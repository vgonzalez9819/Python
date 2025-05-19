const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Database setup
const db = new sqlite3.Database(path.join(__dirname, 'database.db'));

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    laptop INTEGER,
    charger INTEGER,
    yonderpouch INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Record a return submission
app.post('/api/return', (req, res) => {
  const { name, laptop, charger, yonderpouch } = req.body;
  db.run(
    'INSERT INTO returns (name, laptop, charger, yonderpouch) VALUES (?, ?, ?, ?)',
    [name, laptop ? 1 : 0, charger ? 1 : 0, yonderpouch ? 1 : 0],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, id: this.lastID });
    }
  );
});

// Admin report
app.get('/api/admin/report', (req, res) => {
  db.all('SELECT * FROM returns ORDER BY timestamp DESC', (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
