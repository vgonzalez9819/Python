const { spawn } = require('child_process');
const { existsSync, writeFileSync } = require('fs');
const path = require('path');

const isWin = process.platform === 'win32';

function run(cmd, args, options) {
  const proc = spawn(isWin ? `${cmd}.cmd` : cmd, args, {
    stdio: 'inherit',
    ...options,
  });
  return proc;
}

const serverDir = path.join(__dirname, 'server');
const clientDir = path.join(__dirname, 'client');

// ensure .env exists for server
const envPath = path.join(serverDir, '.env');
if (!existsSync(envPath)) {
  writeFileSync(envPath, 'PORT=3001\n');
  console.log('Created server/.env with default PORT');
}

// install dependencies if node_modules missing
if (!existsSync(path.join(serverDir, 'node_modules'))) {
  run('npm', ['install'], { cwd: serverDir });
}
if (!existsSync(path.join(clientDir, 'node_modules'))) {
  run('npm', ['install'], { cwd: clientDir });
}

// start server
const server = run('npm', ['start'], { cwd: serverDir });

// start client
const client = run('npm', ['start'], { cwd: clientDir });

// open browser after a short delay
setTimeout(() => {
  const url = 'http://localhost:3000';
  const openCmd = isWin ? 'start' : process.platform === 'darwin' ? 'open' : 'xdg-open';
  spawn(openCmd, [url], { stdio: 'ignore' });
}, 5000);

process.on('SIGINT', () => {
  server.kill('SIGINT');
  client.kill('SIGINT');
  process.exit();
});
