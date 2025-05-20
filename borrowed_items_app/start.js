#!/usr/bin/env node
const { spawnSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

function ensureDeps(dir) {
  if (!fs.existsSync(path.join(dir, 'node_modules'))) {
    console.log(`Installing dependencies in ${dir}...`);
    spawnSync('npm', ['install'], { cwd: dir, stdio: 'inherit' });
  }
}

function run(cmd, dir) {
  return spawn(cmd, { cwd: dir, shell: true, stdio: 'inherit' });
}

function openBrowser(url) {
  const platform = process.platform;
  if (platform === 'win32') {
    spawn('cmd', ['/c', 'start', url]);
  } else if (platform === 'darwin') {
    spawn('open', [url]);
  } else {
    spawn('xdg-open', [url]);
  }
}

function main() {
  const root = __dirname;
  const serverDir = path.join(root, 'server');
  const clientDir = path.join(root, 'client');

  ensureDeps(serverDir);
  ensureDeps(clientDir);

  const server = run('npm start', serverDir);
  const client = run('npm start', clientDir);

  openBrowser('http://localhost:3000');

  const kill = () => {
    server.kill();
    client.kill();
  };
  process.on('SIGINT', kill);
  process.on('SIGTERM', kill);
}

main();

