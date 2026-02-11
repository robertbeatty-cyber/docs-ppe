# Regression Test Checklist: ppemedevents.com

**Last updated:** 2026-02-11
**Site:** https://ppemedevents.com
**Staging:** https://staging.ppemedevents.com
**Risk level:** Standard
**Total plugins:** 11 (10 active, 1 inactive)
**Key risk areas:** The Events Calendar + Event Tickets

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
