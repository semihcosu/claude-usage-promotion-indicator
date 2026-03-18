#!/usr/bin/env sh
set -e

REPO="semihcosu/claude-usage-promotion-indicator"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_DIR="${HOME}/.claude/scripts"
SETTINGS_PATH="${HOME}/.claude/settings.json"
COMBINED_CMD="node ${INSTALL_DIR}/combined-statusline.js"

# Require node
if ! command -v node >/dev/null 2>&1; then
  printf 'Error: Node.js is required but not found.\nInstall it from https://nodejs.org\n' >&2
  exit 1
fi

# Require curl
if ! command -v curl >/dev/null 2>&1; then
  printf 'Error: curl is required but not found.\n' >&2
  exit 1
fi

# Create install directory
mkdir -p "${INSTALL_DIR}"

# Download scripts
printf 'Downloading check-promo.js...\n'
curl -fsSL "${BASE_URL}/check-promo.js" -o "${INSTALL_DIR}/check-promo.js"

printf 'Downloading combined-statusline.js...\n'
curl -fsSL "${BASE_URL}/combined-statusline.js" -o "${INSTALL_DIR}/combined-statusline.js"

printf 'Saved to %s\n' "${INSTALL_DIR}"

# Patch ~/.claude/settings.json
node - "${SETTINGS_PATH}" "${COMBINED_CMD}" "${INSTALL_DIR}/check-promo-prev.json" <<'JSEOF'
const fs   = require('fs');
const path = require('path');

const settingsPath = process.argv[2];
const newCmd       = process.argv[3];
const configPath   = process.argv[4];

let settings = {};
if (fs.existsSync(settingsPath)) {
  try {
    settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  } catch (e) {
    process.stderr.write('Error: ' + settingsPath + ' is not valid JSON. Fix it manually and re-run.\n');
    process.exit(1);
  }
}

// Already installed
const currentCmd = (settings.statusLine && settings.statusLine.command) || '';
if (currentCmd === newCmd) {
  process.stdout.write('Already installed — nothing to do.\n');
  process.exit(0);
}

// Save the existing statusLine command so we can restore it on uninstall.
// Always overwrite so a re-install after manually adding a new statusLine captures it.
const prevCmd = currentCmd || null;
fs.writeFileSync(configPath, JSON.stringify({ command: prevCmd }, null, 2) + '\n');
if (prevCmd) {
  process.stdout.write('Saved previous statusLine to ' + configPath + '\n');
}

// Remove stale lowercase key written by an old version of this installer
delete settings.statusline;

// Set new statusLine (correct schema: object with type + command)
settings.statusLine = { type: 'command', command: newCmd };

const dir = path.dirname(settingsPath);
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
process.stdout.write('settings.json updated.\n');
JSEOF

printf '\nDone! Restart Claude Code to activate the status line.\n'
