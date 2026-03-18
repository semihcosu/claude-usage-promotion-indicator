#!/usr/bin/env sh
set -e

INSTALL_PATH="${HOME}/.claude/scripts/check-promo.js"
SETTINGS_PATH="${HOME}/.claude/settings.json"

# Remove script file
if [ -f "${INSTALL_PATH}" ]; then
  rm "${INSTALL_PATH}"
  printf 'Removed %s\n' "${INSTALL_PATH}"
else
  printf 'Script not found at %s — skipping.\n' "${INSTALL_PATH}"
fi

# Remove statusline key from settings.json
if [ ! -f "${SETTINGS_PATH}" ]; then
  printf 'No settings.json found at %s — nothing to clean up.\n' "${SETTINGS_PATH}"
  exit 0
fi

node - "${SETTINGS_PATH}" <<'JSEOF'
const fs   = require('fs');
const path = process.argv[2];

let settings;
try {
  settings = JSON.parse(fs.readFileSync(path, 'utf8'));
} catch (e) {
  process.stderr.write('Error: ' + path + ' is not valid JSON.\n');
  process.exit(1);
}

if (!('statusline' in settings)) {
  process.stdout.write('No statusline key found in settings.json — nothing to remove.\n');
  process.exit(0);
}

delete settings.statusline;
fs.writeFileSync(path, JSON.stringify(settings, null, 2) + '\n');
process.stdout.write('Removed statusline from settings.json.\n');
JSEOF

printf 'Uninstalled. Restart Claude Code to deactivate.\n'
