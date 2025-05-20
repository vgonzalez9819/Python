@echo off
REM Start the Borrowed Items App (Windows)
REM Installs dependencies if needed, starts server and client, and opens browser.

if not exist server\node_modules (
  echo Installing server dependencies...
  pushd server
  npm install
  popd
)

if not exist client\node_modules (
  echo Installing client dependencies...
  pushd client
  npm install
  popd
)

if not exist .env (
  echo PORT=3001> .env
  echo Created default .env
)

start cmd /k "cd server && npm start"
rem Wait a little for the server to start
ping 127.0.0.1 -n 4 > nul
start cmd /k "cd client && npm start"
start http://localhost:3000
