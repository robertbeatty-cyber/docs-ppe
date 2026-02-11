# SOP: Staged Website Updates for PPE Medical

**Version:** 1.0
**Date:** 2026-02-11
**Status:** Active
**Last updated:** 2026-02-11
**Last reviewed by:** Technical Lead
**Applies to:** Maintenance Technician, Technical Lead
**Purpose:** Provide a controlled, repeatable process for applying WordPress updates across PPE Medical's three websites using staging environments to prevent production issues

---

## Prerequisites

✅ You have access to [MyKinsta](https://my.kinsta.com/) dashboard
✅ You have WordPress admin access to all three PPE Medical sites (production and staging)
✅ You have added your SSH public key to MyKinsta (see [SSH Access Setup](#ssh-access-setup-one-time) below)
✅ You have read this SOP completely before starting your first update cycle
✅ You have access to the regression test checklists in this repository
✅ You have BackstopJS installed locally (see [Visual Regression Testing SOP](visual-regression-testing-SOP.md))
✅ You have access to Clockify for time tracking
✅ WordPress automatic updates are disabled on all three production sites (see [Disable WordPress Auto-Updates](#disable-wordpress-auto-updates-one-time-setup) below)

---

## What is This SOP?

This SOP covers the complete staged update workflow for PPE Medical's three WordPress websites: ppemedical.com, ppetoolkit.com, and ppemedevents.com. It ensures that all plugin and WordPress core updates are tested on staging environments before being applied to production, reducing the risk of downtime or broken functionality.

This procedure runs monthly and covers all three sites in a single update cycle. Estimated time: 1.5-2 hours.

---

## Roles & Responsibilities

### Maintenance Technician
- Executes the full update cycle following this SOP
- Runs regression tests and documents results
- Escalates critical issues to Technical Lead before proceeding
- Logs time in Clockify after completion

### Technical Lead (Escalation)
- Approves LearnDash major version updates on ppetoolkit.com
- Reviews escalated issues and decides on rollback vs. fix
- Communicates with the Site Owner when needed

### Site Owner (Client)
- Notified of any critical issues or extended downtime
- Final authority on whether LearnDash major updates proceed

---

## Disable WordPress Auto-Updates (One-Time Setup)

WordPress has built-in automatic updates for core, plugins, and themes. These must be disabled on every site we manage updates for, otherwise WordPress may apply updates outside our staged process -- bypassing staging testing and potentially breaking production.

### Add to wp-config.php

Add the following lines to `wp-config.php` on each **production** site. These can be added via SFTP, MyKinsta file manager, or SSH:

```php
/** Disable all automatic updates - managed via staged update process */
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'WP_AUTO_UPDATE_CORE', false );
```

| Constant | What It Disables |
|----------|-----------------|
| `AUTOMATIC_UPDATER_DISABLED` | All automatic updates (core, plugins, themes, translations) |
| `WP_AUTO_UPDATE_CORE` | WordPress core auto-updates specifically (belt and suspenders) |

### Disable Plugin Auto-Updates in WordPress Admin

In addition to `wp-config.php`, verify that individual plugin auto-updates are disabled:

1. Go to **Plugins > Installed Plugins**
2. Check the **Automatic Updates** column
3. Any plugin showing "Disable auto-updates" has auto-updates enabled -- click to disable
4. All plugins should show "Enable auto-updates" (meaning auto-updates are currently off)

### Verify Auto-Updates Are Disabled

After adding the constants, verify by going to **Dashboard > Updates** in WordPress admin. You should see a message indicating automatic updates are disabled.

### Sites to Configure

- [ ] ppemedical.com -- `wp-config.php` updated, plugin auto-updates disabled
- [ ] ppetoolkit.com -- `wp-config.php` updated, plugin auto-updates disabled
- [ ] ppemedevents.com -- `wp-config.php` updated, plugin auto-updates disabled

---

## SSH Access Setup (One-Time)

SSH access is required for troubleshooting issues that cannot be resolved through the WordPress admin or MyKinsta dashboard (e.g., white screen errors, locked out of admin, plugin conflicts requiring CLI intervention, reviewing error logs, editing wp-config.php).

### Generate Your SSH Key (if you do not have one)

1. Open your terminal
2. Run the following command (replace the email with your own):
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```
3. Press Enter to accept the default file location
4. Enter a passphrase when prompted (recommended) or press Enter for no passphrase
5. **Verify:** Run `ls ~/.ssh/` -- you should see `id_ed25519` (private key) and `id_ed25519.pub` (public key)

### Add Your SSH Public Key to MyKinsta

1. Copy your public key to clipboard:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Log into [MyKinsta](https://my.kinsta.com/)
3. Click your username (top right) > **User settings**
4. Scroll to the **SSH keys** section
5. Click **Add SSH key**
6. Enter a label (e.g., "Work laptop - [your name]")
7. Paste your public key into the **SSH key** field
8. Click **Add SSH key**
9. **Verify:** Your key appears in the SSH keys list

### Connect via SSH

To connect to any site, find the SSH connection details in MyKinsta:

1. Go to **Sites** > [site name] > **Info**
2. Under **SFTP/SSH**, find the **SSH terminal command**
3. Copy and run it in your terminal:
   ```bash
   ssh [username]@[host] -p [port]
   ```
4. **Verify:** You are connected and see the site's file system

### Common SSH / WP-CLI Tasks

| Task | Command |
|------|---------|
| Check PHP error log | `tail -100 /www/kinsta/logs/error.log` |
| Disable a broken plugin | `wp plugin deactivate [plugin-name]` |
| Disable all plugins (emergency) | `wp plugin deactivate --all` |
| List active plugins | `wp plugin list --status=active` |
| List available updates | `wp plugin list --update=available` |
| Update a single plugin | `wp plugin update [plugin-name]` |
| Update all plugins | `wp plugin update --all` |
| Rollback a plugin (reinstall specific version) | `wp plugin install [plugin-name] --version=[x.y.z] --force` |
| Clear object cache | `wp cache flush` |
| Check WordPress version | `wp core version` |
| Update WordPress core | `wp core update && wp core update-db` |
| Edit wp-config.php | `nano ~/public/wp-config.php` |
| Enable maintenance mode | `wp maintenance-mode activate` |
| Disable maintenance mode | `wp maintenance-mode deactivate` |
| Check site health | `wp site health` |

> **Important:** Never make changes via SSH on production without understanding the impact. When in doubt, escalate to the Technical Lead.

---

## Process Workflow

### Recommended Site Order

Update sites in this order to build confidence from simplest to most complex:

| Order | Site | Plugins | Risk Level | Key Concern |
|-------|------|---------|------------|-------------|
| 1st | ppemedevents.com | 11 | Standard | Events Calendar |
| 2nd | ppemedical.com | 42 | High | WooCommerce + payment processing |
| 3rd | ppetoolkit.com | 42 | **Critical** | LearnDash + custom QBank code |

**Repeat Steps 1-9 for each site, in the order above.**

---

### Step 1 - Pre-Update Preparation

1. Log into [MyKinsta](https://my.kinsta.com/) dashboard
2. Navigate to the site you are updating
3. Check that automatic daily backups are current (Backups tab)
4. Log into the WordPress admin of the **production** site
5. Navigate to **Plugins > Installed Plugins** and note which updates are available
6. Review changelogs for each pending update (click "View version X.X details")
7. **For ppetoolkit.com ONLY:** Check if LearnDash has a major version update pending (e.g., 4.x to 5.x)
   - If a LearnDash **major version** update is pending: **STOP. Do not proceed.**
   - Notify the Technical Lead with the version details
   - The Technical Lead will coordinate with the Site Owner before any major LearnDash update

**Outcome:** You have a clear list of pending updates and have confirmed no blockers exist.

---

### Step 2 - Sync Production to Staging

1. In MyKinsta, navigate to the site's **Environments** section
2. Select the **Production** environment
3. Click **Push environment** and select **Push to Staging**
4. Select **both** "Files" and "Database" to push
5. Confirm the push and wait for it to complete (typically 2-5 minutes)
6. Once complete, log into the **staging** WordPress admin
7. **Verify:** Navigate to a few key pages to confirm staging matches production

**Outcome:** Staging environment is an exact copy of production.

---

### Step 3 - Apply Updates on Staging

Updates can be applied via the WordPress admin dashboard or via WP-CLI over SSH. WP-CLI is faster and provides more control, especially for one-at-a-time updates.

#### Option A: Via WordPress Admin

**For ppemedevents.com (standard risk):**
1. In the staging WordPress admin, go to **Dashboard > Updates**
2. If WordPress core update is available, update core first
3. Go to **Plugins > Installed Plugins**
4. Select all plugins with updates available
5. Apply updates (bulk update is acceptable for this site)
6. Clear all caches: **MyKinsta > Tools > Clear Cache**

**For ppemedical.com (high risk):**
1. Update WordPress core first if available
2. Update plugins **one at a time**, starting with non-WooCommerce plugins
3. Update WooCommerce ecosystem plugins in this order:
   - WooCommerce core
   - WooCommerce Subscriptions
   - Other WooCommerce extensions
4. After each update, do a quick spot-check of the site frontend
5. Clear all caches: **MyKinsta > Tools > Clear Cache**

**For ppetoolkit.com (critical risk):**
1. Update WordPress core first if available
2. **Update LearnDash LMS ALONE first** (no other plugins)
3. After LearnDash update, immediately test QBank functionality:
   - Navigate to a quiz page as a student
   - Verify questions load correctly
   - Verify answer submission works
   - Check the QBank admin interface
4. If QBank works: proceed with remaining plugin updates one at a time
5. If QBank is broken: **STOP immediately.** Do not update other plugins. Notify the Technical Lead.
6. Clear all caches: **MyKinsta > Tools > Clear Cache**

#### Option B: Via WP-CLI over SSH

SSH into the staging environment and use WP-CLI commands. This is faster and gives you more control.

> **Tip:** The [scripts/](../../scripts/) directory contains per-site update scripts that automate the WP-CLI update process and run basic post-update regression checks. See [scripts/README.md](../../scripts/README.md) for usage.

**Connect to staging:**
```bash
ssh [username]@[host] -p [port]
```

**Check available updates:**
```bash
wp core check-update
wp plugin list --update=available
```

**Update WordPress core (if available):**
```bash
wp core update
wp core update-db
```

**For ppemedevents.com -- bulk plugin update:**
```bash
wp plugin update --all
```

**For ppemedical.com -- one at a time, WooCommerce order:**
```bash
# Non-WooCommerce plugins first
wp plugin update elementor elementor-pro yoast-seo-premium

# WooCommerce core, then extensions
wp plugin update woocommerce
wp plugin update woocommerce-subscriptions
wp plugin update [other-woocommerce-extensions]
```

**For ppetoolkit.com -- LearnDash first, alone:**
```bash
# LearnDash ALONE first
wp plugin update sfwd-lms

# Test QBank before continuing (open site in browser)
# If QBank works, proceed:
wp plugin update elementor elementor-pro gravity-forms [other-plugins]
```

**Clear cache after updates:**
```bash
wp cache flush
```

> **Tip:** Use `wp plugin list --update=available --format=table` to see all available updates with current and new version numbers before updating.

**Outcome:** All pending updates are applied on the staging environment.

---

### Step 4 - Regression Test on Staging

1. Open the appropriate regression test checklist for the site:
   - [ppemedical.com checklist](../../checklists/regression-test-ppemedical-com.md)
   - [ppetoolkit.com checklist](../../checklists/regression-test-ppetoolkit-com.md)
   - [ppemedevents.com checklist](../../checklists/regression-test-ppemedevents-com.md)
2. Execute every test item against the **staging** site
3. Document pass/fail results for each item
4. If **critical issues** are found (site errors, broken checkout, broken quizzes, broken event registration):
   - **STOP. Do not proceed to production.**
   - Document the issue with screenshots
   - Notify the Technical Lead with the details
   - Wait for resolution before continuing

**Outcome:** All regression tests pass on staging, or issues are escalated.

---

### Step 5 - Visual Regression Test on Staging (Optional but Recommended)

1. See the [Visual Regression Testing SOP](visual-regression-testing-SOP.md) for step-by-step instructions
2. Run BackstopJS reference capture against the **production** site
3. Run BackstopJS test against the **staging** site
4. Review the HTML report for unexpected visual changes
5. Investigate any flagged differences -- some are expected (e.g., date changes, dynamic content)
6. If unexpected layout breaks are found, investigate before proceeding

**Outcome:** No unexpected visual regressions detected between production and staging.

---

### Step 6 - Create Manual Backup of Production

1. In MyKinsta, navigate to the production environment
2. Go to the **Backups** tab
3. Click **Manual backups**
4. Click **Create backup**
5. Add a label: `Pre-update backup - YYYY-MM-DD - Monthly updates`
6. Wait for the backup to complete
7. **Verify:** The manual backup appears in the backup list with the correct label

**Repeat for each site before updating its production environment.**

**Outcome:** Manual backup exists for each production site, ready for rollback if needed.

---

### Step 7 - Update Production

1. Log into the **production** WordPress admin
2. Apply the **exact same updates** that were tested on staging -- no additional updates
3. Follow the same update approach used for staging:
   - **ppemedevents.com:** Bulk update is acceptable
   - **ppemedical.com:** One at a time, WooCommerce ecosystem in order
   - **ppetoolkit.com:** LearnDash ALONE first, test QBank, then other plugins
4. Clear all caches: **MyKinsta > Tools > Clear Cache**

**Outcome:** Production site is updated with the same versions tested on staging.

---

### Step 8 - Regression Test on Production

1. Execute the same regression test checklist against the **production** site
2. Pay special attention to:
   - **ppemedical.com:** Checkout flow and payment processing
   - **ppetoolkit.com:** QBank quiz functionality and LearnDash course access
   - **ppemedevents.com:** Event calendar views and ticket purchasing
3. If **critical issues** are found on production:
   - **Restore from the manual backup** created in Step 6 (MyKinsta > Backups > Manual > Restore)
   - Notify the Technical Lead immediately
   - Document what went wrong

**Outcome:** Production site passes all regression tests.

---

### Step 9 - Post-Update Documentation

1. Document the update results:
   - Which plugins were updated and to which versions
   - Any issues encountered (even if resolved)
   - Whether visual regression testing was performed
   - Any items that need follow-up
2. Update the plugin version tables in the regression test checklists if versions changed
3. Register time in Clockify:
   - Project: PPE Medical
   - Description: Monthly website updates - [month] [year]
   - Include time for all three sites

**Outcome:** Update cycle is documented and time is logged.

---

## Escalation Criteria

Escalate to the Technical Lead **immediately** if any of the following occur:

| Situation | Action |
|-----------|--------|
| LearnDash major version update is pending | Notify the Technical Lead before starting ppetoolkit.com updates |
| QBank functionality breaks on staging | Stop all ppetoolkit.com updates, notify the Technical Lead |
| Payment processing fails on staging (ppemedical.com) | Stop ppemedical.com updates, notify the Technical Lead |
| Any site shows 500 errors after updates | Restore from backup, notify the Technical Lead |
| Production regression test fails critically | Restore from manual backup, notify the Technical Lead |
| You are unsure whether an issue is critical | Ask the Technical Lead -- when in doubt, escalate |

---

## Common Mistakes & How to Avoid Them

❌ **Mistake:** Updating production without testing on staging first
✅ **Correct approach:** Always sync production to staging, update staging, test, then update production

❌ **Mistake:** Updating all plugins at once on ppetoolkit.com
✅ **Correct approach:** Update LearnDash alone first, verify QBank, then update other plugins one at a time

❌ **Mistake:** Adding extra plugin updates on production that were not tested on staging
✅ **Correct approach:** Only apply the exact same updates tested on staging

❌ **Mistake:** Forgetting to create a manual backup before updating production
✅ **Correct approach:** Always create a labeled manual backup in MyKinsta before each production update

❌ **Mistake:** Ignoring minor visual changes in regression testing
✅ **Correct approach:** Investigate all unexpected changes -- even small layout shifts can indicate bigger problems

❌ **Mistake:** Not clearing caches after updates
✅ **Correct approach:** Always clear MyKinsta cache after applying updates on both staging and production

---

## Verification Checklist

Before marking an update cycle as complete, verify:

- [ ] All three sites updated in the correct order (events -> medical -> toolkit)
- [ ] Staging tested before production for each site
- [ ] Manual backups created for each production site before updates
- [ ] Regression tests passed on both staging and production for each site
- [ ] QBank functionality verified on ppetoolkit.com (if LearnDash was updated)
- [ ] Payment flow verified on ppemedical.com (if WooCommerce was updated)
- [ ] All caches cleared on all environments
- [ ] Plugin version tables updated in checklists
- [ ] Time logged in Clockify
- [ ] Any issues documented and escalated as needed

---

## Related Documents

- [Regression Test Checklist: ppemedical.com](../../checklists/regression-test-ppemedical-com.md)
- [Regression Test Checklist: ppetoolkit.com](../../checklists/regression-test-ppetoolkit-com.md)
- [Regression Test Checklist: ppemedevents.com](../../checklists/regression-test-ppemedevents-com.md)
- [Visual Regression Testing Guide](../../guides/visual-regression-testing-guide.md)

---

*Last reviewed: 2026-02-11*
*Next review: 2026-05-11 (Quarterly)*

---

*This SOP is part of the PPE Medical documentation repository.*
