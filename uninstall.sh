#!/usr/bin/env sh
set -e

INSTALL_DIR="${HOME}/.claude/scripts"
SETTINGS_PATH="${HOME}/.claude/settings.json"
COMBINED_CMD="node ${INSTALL_DIR}/combined-statusline.js"

# Remove installed scripts (check-promo-prev.json removed after settings restore)
for f in check-promo.js combined-statusline.js; do
  fpath="${INSTALL_DIR}/${f}"
  if [ -f "${fpath}" ]; then
    rm "${fpath}"
    printf 'Removed %s\n' "${fpath}"
  fi
done

# Restore settings.json
if [ ! -f "${SETTINGS_PATH}" ]; then
  printf 'No settings.json found at %s — nothing to restore.\n' "${SETTINGS_PATH}"
  exit 0
fi

node - "${SETTINGS_PATH}" "${COMBINED_CMD}" "${INSTALL_DIR}/check-promo-prev.json" <<'JSEOF'
const fs = require('fs');

const settingsPath = process.argv[2];
const ourCmd       = process.argv[3];
const configPath   = process.argv[4];

let settings;
try {
  settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch (e) {
  process.stderr.write('Error: ' + settingsPath + ' is not valid JSON.\n');
  process.exit(1);
}

// Remove stale lowercase key written by an old version of this installer
let dirty = false;
if ('statusline' in settings) {
  delete settings.statusline;
  dirty = true;
  process.stdout.write('Removed stale statusline key.\n');
}

// Only restore/remove statusLine if it's still pointing at our combined script
const currentCmd = (settings.statusLine && settings.statusLine.command) || '';
if (currentCmd !== ourCmd) {
  process.stdout.write('statusLine is not ours — leaving settings.json unchanged.\n');
  if (dirty) fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
  process.exit(0);
}

// Read saved previous statusLine (may not exist if config was already removed above)
let prevCmd = null;
try {
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  prevCmd = cfg.command || null;
} catch (_) {}

if (prevCmd) {
  settings.statusLine = { type: 'command', command: prevCmd };
  process.stdout.write('Restored previous statusLine: ' + prevCmd + '\n');
} else {
  delete settings.statusLine;
  process.stdout.write('Removed statusLine from settings.json.\n');
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
JSEOF

# Clean up the saved previous config now that it's been restored
prevconf="${INSTALL_DIR}/check-promo-prev.json"
if [ -f "${prevconf}" ]; then
  rm "${prevconf}"
  printf 'Removed %s\n' "${prevconf}"
fi

printf 'Uninstalled. Restart Claude Code to deactivate.\n'
