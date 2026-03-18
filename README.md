# Claude Code Usage Promotion Status Line

Shows a live indicator in your [Claude Code](https://claude.ai/code) status line during Anthropic's March 2026 usage promotion — 2× limits during off-peak hours.

**What you'll see:**

| Time | Status line |
|---|---|
| Off-peak hours (2× usage) | `🎉 usage promotion available` |
| Within 2h of off-peak | `⏳ promo in 1h 23m` |
| Peak hours | *(nothing)* |
| After March 30 | `🗑️ promo over — delete this plugin` |

**Promotion schedule (March 13–29, 2026):**
- Weekdays: 2× usage **outside** 8 AM–2 PM ET
- Weekends: 2× usage all day
- Window closes March 29 at 3 AM ET
- [Full details](https://support.claude.com/en/articles/14063676-claude-march-2026-usage-promotion)

---

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/semihcosu/claude-usage-promotion-indicator/main/install.sh | sh
```

> **Security note:** Review the script before running:
> `https://raw.githubusercontent.com/semihcosu/claude-usage-promotion-indicator/main/install.sh`

The installer:
1. Downloads `check-promo.js` to `~/.claude/scripts/`
2. Adds `"statusline"` to `~/.claude/settings.json`
3. Restart Claude Code to activate

**Requirements:** Node.js, curl

---

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/semihcosu/claude-usage-promotion-indicator/main/uninstall.sh | sh
```

Removes `~/.claude/scripts/check-promo.js` and the `statusline` key from `~/.claude/settings.json`.
