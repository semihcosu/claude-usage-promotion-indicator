#!/usr/bin/env node
'use strict';

const { spawnSync } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');

const INSTALL_DIR = path.join(os.homedir(), '.claude', 'scripts');
const CONFIG_PATH = path.join(INSTALL_DIR, 'check-promo-prev.json');

// Promo status — synchronous, no stdin needed
const { getStatus } = require('./check-promo.js');
const promo = getStatus(new Date());

// Previous statusLine command saved at install time (if any)
let prevCmd = null;
try {
  const cfg = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
  prevCmd = cfg.command || null;
} catch (_) {}

// Read stdin (required by the statusLine protocol)
let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);

  let prevOutput = '';
  if (prevCmd) {
    try {
      const result = spawnSync('sh', ['-c', prevCmd], {
        input,
        encoding: 'utf8',
        timeout: 5000,
      });
      prevOutput = (result.stdout || '').trimEnd();
    } catch (_) {}
  }

  const parts = [prevOutput, promo].filter(Boolean);
  if (parts.length) process.stdout.write(parts.join(' │ '));
});
