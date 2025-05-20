#!/usr/bin/env bash
# Start the borrowed items application (backend and frontend)
# Works on Unix/macOS systems.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Starting Borrowed Items App ==="

# Offer docker-compose if available
if [ -f docker-compose.yml ]; then
  echo "docker-compose.yml found. Starting containers..."
  docker-compose up -d
fi

# Ensure root .env
if [ ! -f .env ]; then
  echo "PORT=3001" > .env
  echo "Created default .env file"
fi

# Ensure client .env
if [ ! -f borrowed_items_app/client/.env ]; then
  echo "REACT_APP_API_URL=http://localhost:3001" > borrowed_items_app/client/.env
  echo "Created default client/.env file"
fi

# Install Python requirements if present
if [ -f borrowed_items_app/requirements.txt ]; then
  echo "Installing Python dependencies..."
  pip install -r borrowed_items_app/requirements.txt
elif [ -f requirements.txt ]; then
  echo "Installing Python dependencies..."
  pip install -r requirements.txt
fi

# Install backend dependencies
if [ -f borrowed_items_app/server/package.json ]; then
  if [ ! -d borrowed_items_app/server/node_modules ]; then
    echo "Installing backend dependencies..."
    (cd borrowed_items_app/server && npm install)
  fi
fi

# Install frontend dependencies
if [ ! -d borrowed_items_app/client/node_modules ]; then
  echo "Installing frontend dependencies..."
  (cd borrowed_items_app/client && npm install)
fi

# Ensure html-webpack-plugin is installed
if ! (cd borrowed_items_app/client && npm list html-webpack-plugin >/dev/null 2>&1); then
  echo "Installing html-webpack-plugin..."
  (cd borrowed_items_app/client && npm install html-webpack-plugin)
fi

# Start backend
BACK_PID=""
if [ -f borrowed_items_app/app.py ]; then
  echo "Starting Python backend..."
  (cd borrowed_items_app && python app.py) &
  BACK_PID=$!
elif [ -f borrowed_items_app/server/package.json ]; then
  echo "Starting Node backend..."
  (cd borrowed_items_app/server && npm start) &
  BACK_PID=$!
fi

# Start frontend
echo "Starting React frontend..."
(cd borrowed_items_app/client && npm start) &
FRONT_PID=$!

# Give servers time to start then open browser
sleep 5
URL="http://localhost:3000"
if command -v xdg-open > /dev/null; then
  xdg-open "$URL" >/dev/null 2>&1 &
elif command -v open > /dev/null; then
  open "$URL" &
fi

trap 'kill $BACK_PID $FRONT_PID 2>/dev/null' EXIT
wait $BACK_PID $FRONT_PID
