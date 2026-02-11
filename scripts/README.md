# WP-CLI Update & Regression Test Scripts

**Last updated:** 2026-02-11
**Purpose:** Automate WordPress updates and basic CLI-based regression checks for each PPE Medical site

---

## Overview

These scripts run on Kinsta's server environment via SSH. They automate the update process documented in the [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md) and perform basic post-update checks that can be done from the command line.

**What the scripts automate:**
- Pre-update snapshot (WP version, active plugin count, error log baseline)
- Plugin and core updates in the correct order per site risk level
- Post-update verification (critical plugins still active, key pages return HTTP 200, no new PHP fatal errors, database integrity, cron health)
- Pass/fail summary report

**What still requires manual browser testing:**
- Visual layout and JavaScript errors
- Quiz submission and scoring (ppetoolkit.com)
- Payment processing and checkout flow (ppemedical.com)
- Event ticket purchasing (ppemedevents.com)
- Full regression test checklist items

The scripts print reminders for manual checks at the end of each run.

---

## Scripts

| Script | Site | Risk Level | Update Strategy |
|--------|------|------------|-----------------|
| [update-ppemedevents.sh](update-ppemedevents.sh) | ppemedevents.com | Standard | Core first, then bulk plugin update |
| [update-ppemedical.sh](update-ppemedical.sh) | ppemedical.com | High | Core first, non-WooCommerce plugins, then WooCommerce in order |
| [update-ppetoolkit.sh](update-ppetoolkit.sh) | ppetoolkit.com | **Critical** | Core first, LearnDash ALONE (pause for QBank test), then remaining plugins |

**Recommended run order:** ppemedevents.com -> ppemedical.com -> ppetoolkit.com

---

## Usage

### 1. SSH into the Kinsta environment

Find SSH details in MyKinsta under **Sites > [site name] > Info > SFTP/SSH**.

```bash
ssh [username]@[host] -p [port]
```

### 2. Upload or paste the script

Option A -- copy the script to the server:
```bash
scp -P [port] scripts/update-ppemedevents.sh [username]@[host]:~/
```

Option B -- paste directly into the terminal using a heredoc or nano:
```bash
nano ~/update-ppemedevents.sh
# Paste contents, save with Ctrl+O, exit with Ctrl+X
```

### 3. Make executable and run

```bash
chmod +x ~/update-ppemedevents.sh
bash ~/update-ppemedevents.sh
```

### 4. Review the summary

The script prints a pass/fail summary at the end. Address any failures before proceeding.

### 5. Complete manual testing

After the script finishes, open the site in a browser and complete the full regression test checklist:
- [ppemedevents.com checklist](../checklists/regression-test-ppemedevents-com.md)
- [ppemedical.com checklist](../checklists/regression-test-ppemedical-com.md)
- [ppetoolkit.com checklist](../checklists/regression-test-ppetoolkit-com.md)

---

## Requirements

- WP-CLI (pre-installed on Kinsta)
- curl (pre-installed on Kinsta)
- SSH access to the Kinsta environment

No other dependencies are needed.

---

## Notes

- Scripts auto-detect the site URL via `wp option get siteurl`
- Scripts detect whether the environment is staging or production and warn accordingly
- Scripts are non-destructive -- they only update, never delete or deactivate plugins
- Error log checks only look at new entries added during the update (baseline captured at start)
- The ppetoolkit.sh script pauses after LearnDash update and waits for user confirmation before continuing

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Regression Test Checklists](../checklists/)

---

*Last updated: 2026-02-11*
