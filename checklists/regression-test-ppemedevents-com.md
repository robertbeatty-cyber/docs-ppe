# Regression Test Checklist: ppemedevents.com

**Last updated:** 2026-09-24
**Last executed:** never recorded
**Site:** https://ppemedevents.com
**Staging:** https://staging.ppemedevents.com
**Risk level:** Standard
**Total plugins:** 13 (12 active, 1 inactive), verified on production 2026-09-24
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
- [ ] Password Protected: Verify site is NOT accidentally password-protected (should be publicly accessible)
- [ ] Git Updater: Settings page loads
- [ ] WP File Manager: File manager interface loads in admin

---

## Plugin Version Table

| # | Plugin | Current Version | Update Available |
|---|--------|----------------|-----------------|
| 1 | Event Tickets | 5.27.4 | - |
| 2 | Git Updater | 12.22.0 | - |
| 3 | NinjaFirewall (WP Edition) | 4.8.3 | - |
| 4 | Object Cache Pro | 1.25.1 | - (Inactive) |
| 5 | OttoKit | 1.1.19 | 1.1.20 |
| 6 | Password Protected | 2.7.12 | - |
| 7 | Redirection | 5.6.1 | - |
| 8 | Stream | 4.1.1 | - |
| 9 | The Events Calendar | 6.15.15 | 6.15.16 |
| 10 | WP File Manager | 8.0.2 | - |
| 11 | WP Mail SMTP Pro | 4.7.1 | - |

**Updates currently available (2):** OttoKit 1.1.20, The Events Calendar 6.15.16

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)

---

*Last updated: 2026-02-11*
