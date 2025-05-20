# Borrowed Items Server

This Express.js server provides a simple API for managing borrowed items.
It uses SQLite to store user and item information.

Ensure [Node.js](https://nodejs.org/) is installed so the `npm` command is
available before running the commands below.

## Endpoints

- `POST /api/login` – Authenticate a user.
- `GET /api/items/:userId` – Retrieve items borrowed by a specific user.
- `POST /api/items/:itemId/return` – Mark an item as returned.
- `GET /api/admin/report` – Retrieve a list of all items for administrative purposes.

Run the server with:

```bash
npm install
npm start
```

To populate the database with example data run:

```bash
node seed.js
```
