@echo off
REM start.bat - Launch the Borrowed Items app on Windows

set BASE_DIR=%~dp0
set SERVER_DIR=%BASE_DIR%server
set CLIENT_DIR=%BASE_DIR%client

REM Check that Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Node.js is required. Please install it from https://nodejs.org/
  pause
  exit /b 1
)

REM Create a default .env if needed
if not exist "%SERVER_DIR%\.env" (
  echo PORT=3001 > "%SERVER_DIR%\.env"
  echo Created default %%SERVER_DIR%%\.env
)

REM Install server dependencies if missing
if not exist "%SERVER_DIR%\node_modules" (
  echo Installing server dependencies...
  pushd "%SERVER_DIR%"
  npm install
  popd
)

REM Start the server in a new window
start "Server" cmd /k "cd /d %SERVER_DIR% && npm start"

REM Install client dependencies if missing
if not exist "%CLIENT_DIR%\node_modules" (
  echo Installing client dependencies...
  pushd "%CLIENT_DIR%"
  npm install
  popd
)

REM Start the client in a new window
start "Client" cmd /k "cd /d %CLIENT_DIR% && npm start"

REM Give servers time to start then open browser
ping -n 4 127.0.0.1 >nul
start http://localhost:3000
