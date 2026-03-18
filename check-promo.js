#!/usr/bin/env node
'use strict';

function getStatus(now) {
  try {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: 'America/New_York',
      year:     'numeric',
      month:    'numeric',
      day:      'numeric',
      weekday:  'short',     // 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
      hour:     'numeric',
      minute:   'numeric',
      hourCycle: 'h23',      // 0–23, never 24
    }).formatToParts(now);

    const get  = type => parts.find(p => p.type === type).value;
    const year = parseInt(get('year'),   10);
    const mon  = parseInt(get('month'),  10);
    const day  = parseInt(get('day'),    10);
    const hour = parseInt(get('hour'),   10);
    const min  = parseInt(get('minute'), 10);
    const wday = get('weekday');

    // Integer date for range comparisons e.g. 20260316
    const d = year * 10000 + mon * 100 + day;

    // After March 30: suggest deletion
    if (d >= 20260331) return '🗑️ promo over — delete this plugin';

    // Outside active window (March 13 00:00 ET → March 29 02:59 ET)
    if (d < 20260313 || d > 20260329 || (d === 20260329 && hour >= 3)) return '';

    // Weekend → always on
    if (wday === 'Sat' || wday === 'Sun') return '🎉 usage promotion available';

    // Weekday
    if (hour < 8)  return '🎉 usage promotion available';
    if (hour < 12) return '';
    if (hour < 14) {
      const mins = (14 - hour) * 60 - min;
      return `⏳ promo in ${Math.floor(mins / 60)}h ${mins % 60}m`;
    }
    return '🎉 usage promotion available';

  } catch (_) {
    return '';
  }
}

if (require.main === module) {
  const out = getStatus(new Date());
  if (out) process.stdout.write(out + '\n');
  process.exit(0);
}

module.exports = { getStatus };
