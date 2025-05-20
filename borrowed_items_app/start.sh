#!/bin/bash
# Start the Borrowed Items App (Unix/macOS)
# This script installs dependencies if needed, starts the server and client,
# and opens the web app in the default browser.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Check for Node
if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found. Please install Node.js from https://nodejs.org/"
  exit 1
fi

# Create a .env file if missing
if [ ! -f .env ]; then
  echo "PORT=3001" > .env
  echo "Created default .env in $(pwd)"
fi

# Install backend dependencies
if [ ! -d server/node_modules ]; then
  echo "Installing server dependencies..."
  (cd server && npm install)
fi

# Install frontend dependencies
if [ ! -d client/node_modules ]; then
  echo "Installing client dependencies..."
  (cd client && npm install)
fi

# Start backend
(cd server && npm start) &
SERVER_PID=$!

# Give server a moment to start
sleep 3

# Start frontend
(cd client && npm start) &
CLIENT_PID=$!

# Open application in default browser
URL="http://localhost:3000"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1
elif command -v open >/dev/null 2>&1; then
  open "$URL"
fi

wait $SERVER_PID $CLIENT_PID
