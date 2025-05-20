# Borrowed Items Server

This Express.js server provides a simple API for managing borrowed items.
It uses SQLite to store user and item information.

## Endpoints

- `POST /api/login` – Authenticate a user.
- `GET /api/items/:userId` – Retrieve items borrowed by a specific user.
- `POST /api/items/:itemId/return` – Mark an item as returned.
- `GET /api/admin/report` – Retrieve a list of all items for administrative purposes.

Requires Node.js and npm.

Run the server with:

```bash
npm install
npm start
```

You can also launch both the server and React client at once with
`start_app.sh` (Unix/macOS) or `start_app.bat` (Windows) from the project
root.
