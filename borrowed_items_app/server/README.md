# Borrowed Items Server

This Express.js server provides a simple API for managing borrowed items.
It uses SQLite to store user and item information.

## Prerequisites

Make sure [Node.js](https://nodejs.org/) (which includes `npm`) is installed on
your system before continuing.

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

Alternatively, run the `start.sh` (Unix) or `start.bat` (Windows) script from
the parent `borrowed_items_app` directory to launch the entire application.

To populate the database with sample data, run:

```bash
node seed.js
```
