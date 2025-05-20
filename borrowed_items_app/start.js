#!/usr/bin/env node
const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const root = __dirname;
const serverDir = path.join(root, 'server');
const clientDir = path.join(root, 'client');

function ensureDeps(dir) {
  if (!fs.existsSync(path.join(dir, 'node_modules'))) {
    console.log(`Installing dependencies in ${dir}`);
    execSync('npm install', { cwd: dir, stdio: 'inherit' });
  }
}

function ensureEnv(dir) {
  const env = path.join(dir, '.env');
  if (!fs.existsSync(env)) {
    console.log(`Creating empty .env in ${dir}`);
    fs.writeFileSync(env, '');
  }
}

ensureDeps(serverDir);
ensureDeps(clientDir);
ensureEnv(serverDir);
ensureEnv(clientDir);

console.log('Starting server and client...');
const server = spawn('npm', ['start'], { cwd: serverDir, stdio: 'inherit', shell: true });
const client = spawn('npm', ['start'], { cwd: clientDir, stdio: 'inherit', shell: true });

const url = 'http://localhost:3000';
function openBrowser() {
  const command = process.platform === 'darwin'
    ? 'open'
    : process.platform === 'win32'
      ? 'start'
      : 'xdg-open';
  spawn(command, [url], { shell: true, stdio: 'ignore' });
}

setTimeout(openBrowser, 5000);

process.on('SIGINT', () => {
  server.kill('SIGINT');
  client.kill('SIGINT');
  process.exit();
});
