# Borrowed Items Server

This Express.js server records student self-attestations for returning equipment.
It uses SQLite to store each submission.

## Endpoints

- `POST /api/return` – Record that a student returned items.
- `GET /api/admin/report` – Retrieve all return submissions for administrative purposes.

Run the server with:

```bash
npm install
npm start
```
