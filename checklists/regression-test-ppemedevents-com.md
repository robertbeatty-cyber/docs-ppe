# Regression Test Checklist: ppemedevents.com

**Last updated:** 2026-10-29
**Last executed:** 2026-10-28 (staging, then production). **Section 2b failed on production, then fixed the same day:** the REST API was public after the Password Protected 2.8.5 update. "Allow REST API" was turned off and both the Kinsta server cache and the Edge cache were cleared, after which all REST checks passed (see 2b)
**Site:** https://ppemedevents.com
**Staging:** https://staging.ppemedevents.com
**Risk level:** Standard
**Total plugins:** 13 (12 active, 1 inactive), plus 4 must-use, verified on production 2026-10-28
**Key risk areas:** The Events Calendar + Event Tickets + **Promoter sync through the password wall (see Section 2b)**

> **The whole site is deliberately behind a site-wide password** (Password Protected plugin).
> The client wants event dates and RSVP details hidden. An unauthenticated call to the REST
> API **returns 401 "Only authenticated users can access the REST API". That is correct.**
> Promoter (209.87.149.23) gets through by IP, and OttoKit's `sure-triggers/v1` namespace is
> allowlisted by the mu-plugin `gd-pp-allowlist-ppemedevents.php`. Read the ppemedevents
> runbook in `ansible-v2/docs/clients/ppemedevents.md` before changing anything here.
>
> **Why Section 2b exists.** Between June and August 2026 this site had four incidents, all
> in the same place: Promoter could not get through to the REST API, so attendees stopped
> syncing and event emails stopped going out. OST #620213, #878267 (cURL 35, TLS),
> #594224 and #970742. Three of the four did not follow an update, so running this
> section monthly catches them by luck. The automated check in
> [`tests/http/ppemedevents-rest-checks.sh`](../tests/http/ppemedevents-rest-checks.sh)
> covers the wall and TLS. Only the access log shows whether Promoter is getting through.

---

## 1. General Site Functionality

- [ ] Homepage loads correctly
- [ ] Main navigation menu works (all top-level and dropdown items)
- [ ] Footer links work correctly
- [ ] Mobile responsive layout displays correctly
- [ ] No JavaScript console errors on key pages (homepage, calendar, event page)
- [ ] SSL certificate is valid (padlock icon in browser)
- [ ] Site loads within acceptable time

---

## 2. The Events Calendar

- [ ] Calendar main page loads (/events/ or similar)
- [ ] Month view displays events correctly
- [ ] List view displays events correctly
- [ ] Day view works (if enabled)
- [ ] Individual event pages load with correct content (title, date, time, venue, description)
- [ ] Event filtering works (by category, date range, etc.)
- [ ] Calendar navigation works (next/previous month, date picker)
- [ ] Past events are accessible (if configured)
- [ ] Upcoming events display correctly

---

## 2b. Promoter Sync Through the Password Wall (highest-risk area on this site)

Run this on **production** after every update, and whenever event emails are reported as not arriving.

- [ ] Run `bash tests/http/ppemedevents-rest-checks.sh`. All checks pass: REST is walled (401), `sure-triggers/v1` is reachable (200), TLS negotiates
- [ ] **Settings > Password Protected > "Allow REST API" is OFF** (`wp option get password_protected_rest` returns `0`). With it on, Password Protected 2.8.5 and later serve the REST API to anyone. Earlier versions had a bug that blocked REST anyway, which is why the site looked walled while the setting was on. The Promoter and OttoKit exceptions do not depend on this setting
- [ ] **After any change to the wall, clear both Kinsta caches before testing:** MyKinsta > Tools > Clear cache **and** MyKinsta > Caching > Edge Caching > Clear cache. Kinsta's Edge cache stores REST responses for up to 24 hours (`s-maxage=86400`), so without both clears the check reports the cached copy, not the live site. A response header `x-kinsta-cache: HIT` means you are looking at the cache
- [ ] **Promoter is getting through.** Over SSH, the recent Promoter requests in the access log return 200 (the logs keep only about 3 days):
  ```bash
  grep -h 209.87.149.23 ~/logs/access.log* | awk '{print $8}' | sort | uniq -c
  ```
  Expect only `200`. Any `401` means Promoter is being blocked by the wall
- [ ] Both mu-plugins are present: `gd-password-protected-allowlist.php` and `gd-pp-allowlist-ppemedevents.php` (`wp plugin list --status=must-use`)
- [ ] `wp option get password_protected_allowed_ip_addresses` still contains `209.87.149.23`
- [ ] OttoKit shows as connected in WP Admin

**If REST returns 200, the wall is down.** Event data is then public, which the client
treats as business-critical. Escalate immediately.

**If Promoter shows an authentication or sync error banner, do not click "reset the
authorization".** The banner is known to persist after the problem has cleared (Liquid Web
case #52250357). Check the access log first. A reset tears down a working connection.

---

## 3. Event Tickets

- [ ] Events with tickets display ticket options correctly
- [ ] Ticket purchase/registration flow works (add ticket, fill in details)
- [ ] Checkout/confirmation process completes
- [ ] Confirmation email is sent after ticket purchase/registration
- [ ] RSVP functionality works (if configured on any events)
- [ ] Ticket availability displays correctly (sold out vs. available)

---

## 4. Security

- [ ] NinjaFirewall: Firewall status shows "Enabled" in admin
- [ ] NinjaFirewall: No blocked requests that indicate misconfiguration

---

## 5. Redirections

- [ ] Redirection plugin: Settings page loads in admin
- [ ] Test 1-2 known redirects to confirm they still work
- [ ] Check redirect logs for any new 404 errors

---

## 6. Email Delivery

- [ ] WP Mail SMTP Pro: Settings page loads, connection status shows "Connected"
- [ ] Test email delivery (submit a form or trigger a notification)
- [ ] Check email logs if available (WP Mail SMTP Pro > Email Log)

---

## 7. Other Plugins

- [ ] OttoKit: Dashboard loads, automations are running (if configured)
- [ ] Stream: Activity log shows recent events in admin
- [ ] Password Protected: the site **is** password-protected. Logged out, `/events/` redirects to the password form (this is deliberate, see the note at the top)
- [ ] Git Updater: Settings page loads. If it reports "API rate limit exceeded" it cannot see updates for Gorilla Essentials or the child theme; retry later
- [ ] Gorilla Essentials: version matches the other two sites. If Git Updater says "Automatic update is unavailable", see SOP Step 2 (token + Refresh Cache)
- [ ] Temporary Login Without Password: Settings page loads
- [ ] WP File Manager: File manager interface loads in admin. Its `open_basedir` warnings in the PHP error log (`backup-storage.php` line 119, about 1,000 a day) were already there before the 2026-10-28 update

---

## Plugin Version Table

**Captured from production 2026-10-28, after the October round**, via `wp plugin list --fields=name,title,status,version,update_version --format=csv`.

**Pending at capture: 0 plugin updates, 0 theme updates.** WordPress core 7.1.3 at capture (7.1.4 from 2026-10-29), child theme `child-ppemedevents` 1.0.2 (parent Twenty Ten 4.7). Git Updater was rate-limited by GitHub at capture, so updates for Gorilla Essentials and the child theme could not be checked.

| # | Plugin | Slug | Version |
|---|--------|------|---------|
| 1 | Event Tickets | `event-tickets` | 5.30.2 |
| 2 | Git Updater | `git-updater` | 14.4.3 |
| 3 | Gorilla Essentials | `gorilla-essentials` | 0.3.17 (updated from 0.1.5 later on 2026-10-28) |
| 4 | NinjaFirewall (WP Edition) | `ninjafirewall` | 4.9.2 |
| 5 | OttoKit (SureTriggers) | `suretriggers` | 1.1.42 |
| 6 | Password Protected | `password-protected` | 2.8.5 |
| 7 | Redirection | `redirection` | 5.10.1 |
| 8 | Stream | `stream` | 4.4.0 |
| 9 | Temporary Login Without Password | `temporary-login-without-password` | 1.9.10 |
| 10 | The Events Calendar | `the-events-calendar` | 6.18.2 |
| 11 | WP File Manager | `wp-file-manager` | 8.0.6 |
| 12 | WP Mail SMTP Pro | `wp-mail-smtp-pro` | 4.10.3 |

### Inactive (installed, not active)

| Plugin | Slug | Version |
|--------|------|---------|
| Object Cache Pro | `object-cache-pro` | 1.25.1 |

### Must-use

| Plugin | Slug | Version |
|--------|------|---------|
| GD Password Protected Allowlist | `gd-password-protected-allowlist` | 1.0.0 |
| GD PP Allowlist - ppemedevents | `gd-pp-allowlist-ppemedevents` | 1.1.0 |
| Kinsta MU Plugins | `kinsta-mu-plugins` | 3.6.1 |
| NinjaFirewall WP (mu-plugin) | `0-ninjafirewall` | 1.0 |

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)

---

*Last updated: 2026-10-29*
