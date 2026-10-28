# SOP: Staged Website Updates for PPE Medical

**Version:** 1.5
**Date:** 2026-02-11
**Status:** Active
**Last updated:** 2026-10-28 (v1.5 added the October 2026 walkthrough video and where it differs from this SOP; email blocking set once on production so each push carries it to staging; a production console-check baseline before updating; closing the monthly ticket; a revised time estimate. v1.4, 2026-10-29, from the October 2026 cycle, added: the update window; staging email blocking via Gorilla Essentials, with why "Always" beats "Automatic"; staging checkout setup for ppemedical.com (Stripe test mode, SaferCheckout country block); staging license-error notes; the Password Protected REST check and two-cache clear for ppemedevents.com; the warning that deleting Gorilla Essentials wipes its pins; testing ppetoolkit.com as a non-`student` role; the LearnDash pin lifted; v1.3 added "Pinning a Plugin Version (Gorilla Essentials)"; v1.2, 2026-07-14, added the per-site browser console regression checks in tests/console/ to Steps 4 & 8 and the Out-of-Cycle section; v1.1 added the non-admin testing rule after the 2026-07-07 ppetoolkit.com LearnDash/Elementor blank-content incident)
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
✅ You have the per-site browser console checks in [tests/console/](../../tests/console/) and know how to run them (see [Browser Console Regression Checks](../../guides/browser-console-regression-checks.md))
✅ You have the dedicated test-account logins from the team password manager (see [Test Accounts](../../reference/test-accounts.md)) -- do not borrow real users' logins
✅ You have BackstopJS installed locally (see [Visual Regression Testing SOP](visual-regression-testing-SOP.md))
✅ You have access to Clockify for time tracking
✅ WordPress automatic updates are disabled on all three production sites (see [Disable WordPress Auto-Updates](#disable-wordpress-auto-updates-one-time-setup) below)

---

## What is This SOP?

This SOP covers the complete staged update workflow for PPE Medical's three WordPress websites: ppemedical.com, ppetoolkit.com, and ppemedevents.com. It ensures that all plugin and WordPress core updates are tested on staging environments before being applied to production, reducing the risk of downtime or broken functionality.

This procedure runs monthly and covers all three sites in a single update cycle. Allow **3-4 hours** for all three sites (estimate). ppemedical.com alone took about 1.5 hours in the October 2026 walkthrough below, most of it regression testing.

---

## Watch the Walkthrough First

Watch **[the October 2026 ppemedical.com update cycle (Loom, about 85 min)](https://www.loom.com/share/3b2fe01330184433b6e51996fe6a409e)** before your first run. It covers ppemedical.com only; ppemedevents.com and ppetoolkit.com follow the same steps with their own checklists.

| Time | What happens |
|------|--------------|
| 0:00 | Access you need: MyKinsta and this repository |
| 1:21 | Site order, and why ppemedical.com went first this time |
| 2:01 | Checking staging before the push: email blocked, environment badge |
| 3:46 | Updating Gorilla Essentials on staging; Site Hygiene email blocking |
| 7:29 | Push live to staging (the other two sites are pushed at 12:04 and 12:39) |
| 13:08 | The checklists in this repo; console check run on production as a baseline (15:13) |
| 19:32 | Staging ready: confirming email is blocked (Site Hygiene at 20:50) |
| 23:04 | Applying plugin updates on staging; reading changelogs |
| 28:41 | License errors on staging; more updates appearing after WooCommerce |
| 32:02 | WordPress core and child theme updates |
| 33:30 | Regression checklist on staging; clearing caches (36:23) |
| 41:41 | Console checks on cart and checkout |
| 47:02 | Connecting a Stripe test account on staging |
| 51:31 | SaferCheckout Lite country block; successful test order at 54:18 |
| 55:06 | Confirming the order email did not go out |
| 1:01:24 | Update window: the client is in California |
| 1:03:27 | Production manual backup; deleting old backups |
| 1:06:09 | Production updates |
| 1:10:11 | Authorize.Net plugins on production |
| 1:17:33 | Clearing caches, production checks, console check at checkout |
| 1:22:25 | Close-out: checklist version tables, the monthly ticket |

**Where the video and this SOP differ, this SOP wins.** The steps below include what was learned in that cycle, after the video was recorded:

| In the video | Follow this instead |
|--------------|---------------------|
| Select all > Update plugins on ppemedical.com (23:04, 1:06:09) | One plugin at a time, WooCommerce ecosystem in order. No Select all on this site (Steps 3 and 7) |
| Plugins first, WordPress core last (32:02) | WordPress core first, then plugins (Step 3) |
| Staging email blocking set to "Automatic" (21:10) | **"Always block outside production, including a hostname guess"**, set once on production so every push carries it (see [Block Staging Email at the Source](#block-staging-email-at-the-source-one-time-setup)) |
| Authorize.Net described as replaced by Stripe and to be left inactive (25:11, 1:10:11 to 1:15:49) | The Authorize.Net (Enterprise) gateway stays **enabled** for subscription renewals, hidden from checkout only. **Both** Authorize.Net plugins stay active. See Section 3 of the [ppemedical.com checklist](../../checklists/regression-test-ppemedical-com.md) |
| Production updates started at about 6:30 PM Pacific (1:01:24) | Production inside the 8 PM to 5 AM Pacific window (see [Update Window](#update-window)) |

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

## Block Staging Email at the Source (One-Time Setup)

A live-to-staging push copies production's database, Gorilla Essentials settings included. If production says "never block", every fresh staging copy can email real customers until someone changes it. That is what the October 2026 walkthrough found at 20:22. Set the block once **on production**, and every push brings it to staging.

1. Make sure production runs a Gorilla Essentials version that has **Site Hygiene** (0.3.x or later, see Step 2)
2. In the **production** admin, go to **Tools > Gorilla Essentials > Site Hygiene**
3. Set **Block outbound email** to **"Always block outside production, including a hostname guess"** and save. This blocks every environment **except** production.
4. **Verify production still sends.** The Site Hygiene screen must **not** show "Outbound email is being blocked right now". Over SSH, `wp eval '$g=new GorillaEssentials_Email_Guard(); echo json_encode($g->status());'` must show `"blocking":false`. Then send a test from **WP Mail SMTP > Tools > Email Test** to your own address and confirm it arrives. If production reports blocking, set the option back at once and escalate to the Technical Lead: production must send order and subscription emails.
5. Step 2 still checks staging after every push. This setting makes the block the default; it does not replace the check.

### Sites to Configure

- [ ] ppemedical.com -- production set, production sending verified
- [ ] ppetoolkit.com -- production set, production sending verified
- [ ] ppemedevents.com -- production set, production sending verified

---

## Pinning a Plugin Version (Gorilla Essentials)

When a plugin release is known to break a site, we **pin** it at the last known-good version instead of relying on everyone remembering not to update it. Pins are managed by the **Gorilla Essentials** plugin (Gorilla DevOps, source repo `gorilla-essentials`), which is installed and active on all three production sites.

### What a pin does

A pin is enforced in four places, so it holds however the update is attempted:

| Layer | Effect |
|-------|--------|
| Update list | Updates **above** the pinned version are hidden from Dashboard > Updates, the Plugins screen and `wp plugin list --update=available` |
| Auto-updates | Refused for any version above the pin |
| Manual / WP-CLI install | Blocked with the error `Update blocked -- <plugin> is version-locked` (the error text contains an em dash; it is quoted here with `--`) |
| Admin notice | A notice on the Plugins screen and an inline "locked" row under the plugin |

Updates **at or below** the pinned version are still allowed. A pin can also freeze WordPress core (**WordPress Core** section on the same tab).

### Currently pinned (verified 2026-10-29)

| Site | Plugin | Pinned at | Reason |
|------|--------|-----------|--------|
| ppetoolkit.com | none | - | LearnDash was pinned at 5.1.4 from 2026-07-08 to 2026-10-29 (#218633). Lifted after user roles were given `read`; see [the finding](../../reference/ppetoolkit-learndash-read-capability.md) |
| ppemedical.com | none | - | - |
| ppemedevents.com | none | - | - |

Pins are stored in the database (the `gorilla_essentials_settings` option), so a production-to-staging push copies them to staging. **Deleting the Gorilla Essentials plugin deletes that option, and every pin with it.** Write the settings down before deleting or reinstalling the plugin, and re-enter them afterwards.

### Add, change or remove a pin

1. Go to **Tools > Gorilla Essentials > Plugin Locks**
2. **Add a Pin:** choose the plugin, enter the version to hold at, and write a note that gives the **reason and the ticket number**. The note is shown to anyone who tries to update the plugin.
3. **Lift a pin:** switch it off, or tick **Remove**, then save. Do this on staging first and test the new version there. Lift it on production only once staging has passed.

Read-only check over SSH:

```bash
wp option get gorilla_essentials_settings --format=json | grep -o '"locks".*'
```

### When to pin

- A release has broken staging or production, and the vendor has not yet shipped a fix
- The Technical Lead has asked for a plugin to be held (for example, while waiting for a vendor fix)

Record each pin in the site's regression checklist so the next person knows why it is held and what "fixed" looks like.

### During an update cycle

- A pinned plugin **will not appear** in the list of available updates. This is expected, not a fault.
- Before lifting a pin, confirm the new version fixes the original problem **on staging**, using the test that caught it. Find the cause, not just the symptom: the 2026-07 LearnDash pin was set for a "non-admin" bug that turned out to be roles missing `read`.

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
| 1st | ppemedevents.com | 12 | Standard | Events Calendar + password wall |
| 2nd | ppemedical.com | 46 | High | WooCommerce + payment processing |
| 3rd | ppetoolkit.com | 37 | **Critical** | LearnDash + custom QBank code, roles need `read` |

**Repeat Steps 1-9 for each site, in the order above.** Doing ppemedical.com first is acceptable when you want more of the update window for the longest site, as in the walkthrough video.

> **Tip:** A live-to-staging push takes several minutes and locks the environment while it runs. Start the Step 2 push for all three sites at the beginning of the session so each staging copy is ready when you reach it.

### Update Window

The client is in California (Pacific time). Apply **production** updates (Step 7) outside their business hours, ideally **8 PM to 5 AM Pacific**. Staging work (Steps 2-5) can happen any time. If you are new to this process, start production early in the window so there is time to restore and retest before morning.

---

### Step 1 - Pre-Update Preparation

1. Log into [MyKinsta](https://my.kinsta.com/) dashboard
2. Navigate to the site you are updating
3. Check that automatic daily backups are current (Backups tab)
4. Log into the WordPress admin of the **production** site
5. Navigate to **Plugins > Installed Plugins** and record which updates are available, with current and new versions, in the monthly ticket (`wp plugin list --update=available --format=table` over SSH). Do this **before** updating anything: once staging is updated, the list is gone, and you need it to apply the same updates on production
6. Review changelogs for each pending update (click "View version X.X details")
7. **For ppetoolkit.com ONLY:** Check if LearnDash has a major version update pending (e.g., 4.x to 5.x)
   - If a LearnDash **major version** update is pending: **STOP. Do not proceed.**
   - Notify the Technical Lead with the version details
   - The Technical Lead will coordinate with the Site Owner before any major LearnDash update
8. Run the site's [browser console check](../../tests/console/) on **production** as a baseline, on the same pages you will test later. A `WARN` or console error that is already there before you update is not caused by the update.

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
8. **Confirm outbound email is blocked on staging.** The push copies production's settings. With the [one-time production setting](#block-staging-email-at-the-source-one-time-setup) in place, staging arrives already blocking; without it, staging arrives able to email real customers. In the staging admin, go to **Tools > Gorilla Essentials > Site Hygiene** and check that **Block outbound email** is **"Always block outside production, including a hostname guess"**. If it is not, set it and save, then set it on production too.
   - **Why "Always" rather than "Automatic".** Kinsta staging sets `WP_ENVIRONMENT_TYPE=staging` as a server environment variable for **web** requests, so "Automatic" does block there (the Site Hygiene screen shows "Outbound email is being blocked right now"). WP-CLI sessions do **not** get that variable: from the CLI the same staging site reports `production`, and "Automatic" does not block. Anything that sends mail through WP-CLI, including a host-run system cron, would get through. ppemedical.com staging has `DISABLE_WP_CRON` set, so its scheduled jobs (subscription emails) are run by the host, not by page visits. "Always" blocks in both contexts (verified 2026-10-28: ppemedical.com staging, CLI, `blocking: true`). On ppemedevents.com, WP-Cron runs over HTTP, so "Automatic" also works there, but "Always" is the safe default for every staging site.
   - **Verify:** the Gorilla Essentials environment badge shows staging, and the Site Hygiene screen shows **"Outbound email is being blocked right now"**. If WP Mail SMTP Pro reports that sending is blocked, that is expected.
   - Gorilla Essentials replaces the separate "disable emails" plugin that was previously used on staging. Do not install it again.
   - Never set email blocking on **production** in a way that stops it sending. Production must send order and subscription emails.
   - **Gorilla Essentials must be 0.3.x** for Site Hygiene to exist. ppemedevents.com was stuck on 0.1.5 until 2026-10-28. The likely cause: its Git Updater token for the private `gorilla-devops/gorilla-essentials` repo was an older 40-character token that no longer worked (not tested directly), and the shared Kinsta IP had used up GitHub's anonymous rate limit ("API rate limit exceeded", "Automatic update is unavailable for this plugin"). Fix: put a working token in **Settings > Git Updater > Settings > GitHub**, click **Refresh Cache**, then update.
   - **Checking from WP-CLI:** `wp eval '$g=new GorillaEssentials_Email_Guard(); echo json_encode($g->status());'` shows `"blocking":true` on staging only when the setting is "Always". With "Automatic" it shows `false` from the CLI even though web requests are blocked (see above), so a `false` there on "Automatic" is not proof that the web side sends.

> **Note:** Pushing live to staging changes the staging server's SSH host key. If you try to SSH into staging after a push and see a "REMOTE HOST IDENTIFICATION HAS CHANGED" error, clear the old key first (quotes required in zsh):
> ```bash
> ssh-keygen -R '[146.148.59.197]:17181'
> ```
> Then reconnect and accept the new key when prompted.

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
7. If **Password Protected** was updated, run `bash tests/http/ppemedevents-rest-checks.sh` straight away (production) and confirm **Settings > Password Protected > Allow REST API** is **off**. Version 2.8.5 fixed a bug that had been keeping REST blocked with that setting on, and the 2026-10-28 update exposed the REST API publicly as a result. If you change that setting, clear **both** the Kinsta server cache (Tools > Clear cache) and the **Edge cache** (Caching > Edge Caching > Clear cache) before rerunning the check: the Edge cache keeps serving the old public REST responses for up to 24 hours.

**For ppemedical.com (high risk):**
1. Update WordPress core first if available
2. Update plugins **one at a time**, starting with non-WooCommerce plugins
3. Update WooCommerce ecosystem plugins in this order:
   - WooCommerce core
   - WooCommerce Subscriptions
   - Other WooCommerce extensions
4. After each update, do a quick spot-check of the site frontend
5. Clear all caches: **MyKinsta > Tools > Clear Cache**

> **ppemedical.com staging notes (2026-10-28):**
> - Some licensed plugins refuse to update on staging with errors such as "A valid URL was not provided" or "unauthorized". The license is tied to the production domain, so this is expected on staging. Note which plugins they were and confirm they update on production in Step 7.
> - After WooCommerce updates, more WooCommerce extension updates can appear in the list. Run the update again until the list is empty (apart from the license errors above).

**For ppetoolkit.com (critical risk):**
1. Update WordPress core first if available
2. **Update LearnDash LMS ALONE first** (no other plugins)
3. After LearnDash update, immediately test QBank functionality:
   - Navigate to a quiz page as a student
   - Verify questions load correctly
   - Verify answer submission works
   - Check the QBank admin interface
4. If QBank works: proceed with remaining plugin updates one at a time
   - Check topic/lesson rendering as an enrolled `student` **and** as an enrolled `staff` + `author` or `customer` user. A role without `read` gets blank content from LearnDash 5.1.5 on, and a `student` test alone will not show it
5. If QBank is broken: **STOP immediately.** Do not update other plugins. Notify the Technical Lead.
6. Clear all caches: **MyKinsta > Tools > Clear Cache**

#### Option B: Via WP-CLI over SSH

SSH into the staging environment and use WP-CLI commands. This is faster and gives you more control.

> **Tip:** The [scripts/](../../scripts/) directory contains per-site update scripts that automate the WP-CLI update process and run basic post-update regression checks. See [scripts/README.md](../../scripts/README.md) for usage.

**Connect to staging:**
```bash
ssh [username]@[host] -p [port]
cd ~/public
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

> **Run render/display checks as a non-admin enrolled student, not as an admin (added 2026-07-07).** Admin sessions bypass the page cache and regenerate page assets (e.g. Elementor CSS) on the fly, so they mask cache/asset failures that break the site for students. Keep an admin session open in a second browser for comparison only. Start with **Section 0 (Cache & Asset Integrity)** of the checklist. This is the failure mode behind the 2026-07-07 ppetoolkit.com outage.

1. Open the appropriate regression test checklist for the site:
   - [ppemedical.com checklist](../../checklists/regression-test-ppemedical-com.md)
   - [ppetoolkit.com checklist](../../checklists/regression-test-ppetoolkit-com.md)
   - [ppemedevents.com checklist](../../checklists/regression-test-ppemedevents-com.md)
2. **Fast first pass -- run the site's browser console check** while logged in **in the correct role** (for ppetoolkit.com, the dedicated enrolled non-admin student). Paste the site's file into the Chrome DevTools console on the relevant pages and confirm `0 FAIL`:
   - ppemedical.com: [tests/console/ppemedical-console-checks.js](../../tests/console/ppemedical-console-checks.js) (shop, product, cart, checkout, account)
   - ppetoolkit.com: [tests/console/ppetoolkit-console-checks.js](../../tests/console/ppetoolkit-console-checks.js) (course, lesson, topic, quiz)
   - ppemedevents.com: [tests/console/ppemedevents-console-checks.js](../../tests/console/ppemedevents-console-checks.js) (events list, single event)
   - See [Browser Console Regression Checks](../../guides/browser-console-regression-checks.md) for the page lists and how to read results. A `FAIL` here means stop and investigate before working the rest of the checklist.
3. Execute every test item against the **staging** site. If something looks wrong, check the same page on production before reporting it: some layout issues (for example a spacing issue on the homepage) predate the update
   - **ppemedical.com checkout on staging needs setup first.** After a push, Stripe is not connected on staging and checkout shows no card option. Go to **WooCommerce > Settings > Payments > Stripe > Configure connection** and **create or connect a test account** (a blank Stripe test account is fine), then pay with a Stripe test card (for example `4242 4242 4242 4242`, any future expiry, any CVC).
   - **SaferCheckout Lite blocks checkout from many countries**, including the Philippines. A blocked attempt shows as a **Failed** order with a risk score of 100. On **staging only**, untick your own country under **WooCommerce > Settings > SaferCheckout Lite** (location settings) and save. **Never change this on production.** The next live-to-staging push resets it.
   - The order confirmation email does not arrive on staging because email is blocked (Step 2). That is expected. Confirm the order shows in **WooCommerce > Orders** instead.
4. Document pass/fail results for each item
5. If **critical issues** are found (site errors, broken checkout, broken quizzes, broken event registration):
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
   - Delete manual backups from earlier cycles first if they are no longer needed. On the WooCommerce sites (ppemedical.com) an old backup is not a safe restore point: restoring it would lose every order, renewal and subscription change since it was taken.
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
   - **ppemedical.com:** One at a time, WooCommerce ecosystem in order. Do **not** use Select all > Update on this site, on staging or production
   - **ppetoolkit.com:** LearnDash ALONE first, test QBank, then other plugins
4. Clear all caches: **MyKinsta > Tools > Clear Cache**, plus the site's own cache plugin if it has one
5. Check **Dashboard > Updates** again. Plugins that failed on staging with license errors should update here; anything still pending needs a reason before you move on.

**Outcome:** Production site is updated with the same versions tested on staging.

---

### Step 8 - Regression Test on Production

> **Verify as a non-admin enrolled student (added 2026-07-07).** After clearing caches, confirm as a student that courses/lessons/**Elementor-built topics** render their body content, and that DevTools > Network (CSS filter) shows **no stylesheet 404s**. An admin-only check will pass while students see blank pages -- see Section 0 of the checklist.

1. Run the site's [browser console check](../../tests/console/) first (correct role; ppetoolkit.com as the enrolled non-admin student), then execute the same regression test checklist against the **production** site
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
4. Update the monthly update ticket with the results from item 1, then close it

**Outcome:** Update cycle is documented, time is logged and the ticket is closed.

---

## Out-of-Cycle Updates -- Security, Emergency & Vendor Auto-Updates (added 2026-07-07)

The monthly staged cycle above is not the only way updates reach these sites. Security fixes, emergency single-plugin updates, and vendor-pushed updates (e.g. OttoKit / SureTriggers) are sometimes applied **directly to production, outside this SOP** -- bypassing staging, BackstopJS, and Steps 1-9. This is exactly how the **2026-07-07 ppetoolkit.com outage** happened: a security-round update left Elementor's cached page HTML pointing at a stylesheet version the cache no longer had, and course topics rendered **blank for students only** -- admins saw them fine. Full write-up: `ansible-v2/tmp/ppetoolkit-2026-07-07-learndash-outage-internal.md`.

**Rule: any update applied directly to production -- however small or urgent -- is not "done" until a post-update smoke test is run AS A NON-ADMIN:**

1. Clear **both** caches -- WP Rocket (if active) **and** the Kinsta full-page cache.
2. In a separate/incognito browser, log in as an **enrolled non-admin student** (an admin session bypasses cache and masks this failure).
3. Open a course, a lesson, and an **Elementor-built topic**; confirm the body content and layout render.
4. Run the site's [browser console check](../../tests/console/) on those pages -- it flags blank content, CSS 404s, and (for ppetoolkit.com) whether you are wrongly testing as an admin, in seconds.
5. DevTools > Network > filter CSS > hard-reload: confirm **no stylesheet 404s** (a 404 on `post-<ID>.css` / `custom-frontend.min.css` = blank content for students).
6. If blank for students but fine for admin: **Elementor > Tools > Regenerate CSS & Data**, clear caches, retest. See **Section 0 (Cache & Asset Integrity)** in the site's regression checklist.

If an emergency update can wait, prefer the staged path (Steps 1-9). If it cannot, the non-admin smoke test above is the minimum bar before the change is considered complete.

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

❌ **Mistake:** Testing render/display only while logged in as an admin
✅ **Correct approach:** Run render checks as a non-admin enrolled student -- admins bypass caching and regenerate assets on the fly, so they will not see student-facing breakage (root of the 2026-07-07 ppetoolkit.com outage)

❌ **Mistake:** Treating ad-hoc security/emergency updates as not needing regression testing
✅ **Correct approach:** Any update applied directly to production requires at minimum the non-admin cache & asset smoke test (see "Out-of-Cycle Updates" above)

---

## Verification Checklist

Before marking an update cycle as complete, verify:

- [ ] All three sites updated (events -> medical -> toolkit, or ppemedical.com first)
- [ ] Outbound email confirmed blocked on each staging site after the push
- [ ] Staging tested before production for each site
- [ ] Manual backups created for each production site before updates
- [ ] Regression tests passed on both staging and production for each site
- [ ] QBank functionality verified on ppetoolkit.com (if LearnDash was updated)
- [ ] Payment flow verified on ppemedical.com (if WooCommerce was updated)
- [ ] All caches cleared on all environments
- [ ] Plugin version tables updated in checklists
- [ ] Any pinned plugins are still pinned (Tools > Gorilla Essentials > Plugin Locks), and each pin's note still gives its reason
- [ ] Time logged in Clockify
- [ ] Monthly update ticket updated and closed
- [ ] Any issues documented and escalated as needed

---

## Related Documents

- [Regression Test Checklist: ppemedical.com](../../checklists/regression-test-ppemedical-com.md)
- [Regression Test Checklist: ppetoolkit.com](../../checklists/regression-test-ppetoolkit-com.md)
- [Regression Test Checklist: ppemedevents.com](../../checklists/regression-test-ppemedevents-com.md)
- [Tests (automated regression)](../../tests/README.md)
- [Browser Console Regression Checks](../../guides/browser-console-regression-checks.md)
- [Test Accounts](../../reference/test-accounts.md)
- [Visual Regression Testing Guide](../../guides/visual-regression-testing-guide.md)

---

*Last reviewed: 2026-02-11*
*Next review: 2026-05-11 (Quarterly)*

---

*This SOP is part of the PPE Medical documentation repository.*
