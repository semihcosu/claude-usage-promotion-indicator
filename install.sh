#!/usr/bin/env sh
set -e

REPO="semihcosu/claude-usage-promotion-indicator"
BRANCH="main"
SCRIPT_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/check-promo.js"
INSTALL_DIR="${HOME}/.claude/scripts"
INSTALL_PATH="${INSTALL_DIR}/check-promo.js"
SETTINGS_PATH="${HOME}/.claude/settings.json"
STATUSLINE_CMD="node ${INSTALL_DIR}/check-promo.js"

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

# Download check-promo.js
printf 'Downloading check-promo.js...\n'
curl -fsSL "${SCRIPT_URL}" -o "${INSTALL_PATH}"
printf 'Saved to %s\n' "${INSTALL_PATH}"

# Patch ~/.claude/settings.json
node - "${SETTINGS_PATH}" "${STATUSLINE_CMD}" <<'JSEOF'
const fs   = require('fs');
const path = process.argv[2];
const cmd  = process.argv[3];

let settings = {};
if (fs.existsSync(path)) {
  try {
    settings = JSON.parse(fs.readFileSync(path, 'utf8'));
  } catch (e) {
    process.stderr.write('Error: ' + path + ' is not valid JSON. Fix it manually and re-run.\n');
    process.exit(1);
  }
}

if (settings.statusline === cmd) {
  process.stdout.write('Already installed — nothing to do.\n');
  process.exit(0);
}

if (settings.statusline && settings.statusline !== cmd) {
  process.stderr.write(
    'Error: ' + path + ' already has a statusline set:\n' +
    '  "' + settings.statusline + '"\n\n' +
    'To install, remove that key manually:\n' +
    '  1. Open ' + path + '\n' +
    '  2. Delete the "statusline" line\n' +
    '  3. Re-run the install command\n'
  );
  process.exit(1);
}

const dir = require('path').dirname(path);
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
settings.statusline = cmd;
fs.writeFileSync(path, JSON.stringify(settings, null, 2) + '\n');
process.stdout.write('settings.json updated.\n');
JSEOF

printf '\nDone! Restart Claude Code to activate the status line.\n'
printf 'Inspect the script: %s\n' "${SCRIPT_URL}"
