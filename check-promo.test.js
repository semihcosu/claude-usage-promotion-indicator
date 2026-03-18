'use strict';
const assert = require('assert');
const { getStatus } = require('./check-promo');

// Helper: construct a Date from an ET ISO string.
// All test dates fall after US DST spring-forward on March 8, 2026,
// so ET = EDT = UTC-4 for the entire promotion window.
const et = iso => new Date(iso + '-04:00');

const cases = [
  // --- Before window ---
  ['before window: March 12 noon ET',           et('2026-03-12T12:00:00'), ''],

  // --- Start of window: March 13 (Friday) ---
  ['window start: March 13 00:00 ET (Fri, pre-8am)', et('2026-03-13T00:00:00'), '🎉 usage promotion available'],
  ['March 13 08:00 ET (Fri, peak start)',        et('2026-03-13T08:00:00'), ''],
  ['March 13 11:59 ET (Fri, still peak)',        et('2026-03-13T11:59:00'), ''],
  ['March 13 12:00 ET (Fri, countdown start)',   et('2026-03-13T12:00:00'), '⏳ promo in 2h 0m'],
  ['March 13 13:30 ET (Fri, countdown)',         et('2026-03-13T13:30:00'), '⏳ promo in 0h 30m'],
  ['March 13 14:00 ET (Fri, off-peak starts)',   et('2026-03-13T14:00:00'), '🎉 usage promotion available'],

  // --- Weekend: always on ---
  ['March 14 09:00 ET (Sat)',                    et('2026-03-14T09:00:00'), '🎉 usage promotion available'],
  ['March 15 23:59 ET (Sun)',                    et('2026-03-15T23:59:00'), '🎉 usage promotion available'],

  // --- Weekday boundaries ---
  ['March 16 07:59 ET (Mon, pre-peak)',          et('2026-03-16T07:59:00'), '🎉 usage promotion available'],
  ['March 16 08:00 ET (Mon, peak start)',        et('2026-03-16T08:00:00'), ''],
  ['March 16 11:59 ET (Mon, peak silent)',       et('2026-03-16T11:59:00'), ''],
  ['March 16 12:00 ET (Mon, 2h countdown)',      et('2026-03-16T12:00:00'), '⏳ promo in 2h 0m'],
  ['March 16 12:30 ET (Mon)',                    et('2026-03-16T12:30:00'), '⏳ promo in 1h 30m'],
  ['March 16 13:01 ET (Mon)',                    et('2026-03-16T13:01:00'), '⏳ promo in 0h 59m'],
  ['March 16 13:59 ET (Mon, last countdown min)',et('2026-03-16T13:59:00'), '⏳ promo in 0h 1m'],
  ['March 16 14:00 ET (Mon, off-peak)',          et('2026-03-16T14:00:00'), '🎉 usage promotion available'],
  ['March 16 23:59 ET (Mon, late)',              et('2026-03-16T23:59:00'), '🎉 usage promotion available'],

  // --- End of window ---
  ['March 29 02:59 ET (Sun, last minute)',       et('2026-03-29T02:59:00'), '🎉 usage promotion available'],
  ['March 29 03:00 ET (window closed)',          et('2026-03-29T03:00:00'), ''],

  // --- Silent gap ---
  ['March 29 noon ET (gap)',                     et('2026-03-29T12:00:00'), ''],
  ['March 30 noon ET (gap)',                     et('2026-03-30T12:00:00'), ''],

  // --- Deletion reminder ---
  ['March 31 00:00 ET',                          et('2026-03-31T00:00:00'), '🗑️ promo over — delete this plugin'],
  ['April 15 noon ET',                           new Date('2026-04-15T16:00:00Z'), '🗑️ promo over — delete this plugin'],
];

let passed = 0;
let failed = 0;

for (const [desc, date, expected] of cases) {
  const actual = getStatus(date);
  if (actual === expected) {
    console.log(`  ✓ ${desc}`);
    passed++;
  } else {
    console.error(`  ✗ ${desc}`);
    console.error(`    expected: ${JSON.stringify(expected)}`);
    console.error(`    actual:   ${JSON.stringify(actual)}`);
    failed++;
  }
}

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
