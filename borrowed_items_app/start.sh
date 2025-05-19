#!/usr/bin/env bash
# start.sh - Launch the Borrowed Items app (server and client)
# This script installs dependencies, starts the backend and frontend,
# and opens the app in the default browser.

set -e

# Determine directories
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$BASE_DIR/server"
CLIENT_DIR="$BASE_DIR/client"

# Ensure Node.js is installed
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required. Please install it from https://nodejs.org/" >&2
  exit 1
fi

# Optional .env file
ENV_FILE="$SERVER_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "PORT=3001" > "$ENV_FILE"
  echo "Created default $ENV_FILE"
fi

# Install server dependencies if missing
if [ ! -d "$SERVER_DIR/node_modules" ]; then
  echo "Installing server dependencies..."
  (cd "$SERVER_DIR" && npm install)
fi

# Start server in the background
(cd "$SERVER_DIR" && npm start &) 
SERVER_PID=$!

# Install client dependencies if missing
if [ ! -d "$CLIENT_DIR/node_modules" ]; then
  echo "Installing client dependencies..."
  (cd "$CLIENT_DIR" && npm install)
fi

# Start client in the background
(cd "$CLIENT_DIR" && npm start &) 
CLIENT_PID=$!

# Wait briefly to let dev servers start
sleep 3

# Open the app in the default browser
URL="http://localhost:3000"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
  open "$URL" >/dev/null 2>&1 &
else
  echo "Please open $URL in your browser"
fi

# Wait for background processes
wait $SERVER_PID $CLIENT_PID
