# Test Accounts

**Last updated:** 2026-07-14
**Purpose:** Document the logins used for regression testing across the three PPE Medical sites, and why ppetoolkit.com testing must use an enrolled **non-admin student**. Passwords are NOT stored here (see Credential handling below).

---

## Credential handling (decision D2)

- **No passwords live in this file or anywhere in this repo.** Each account's password lives in the **team password manager**; the entries below are pointers to it.
- Do not paste credentials into client-facing docs, tickets, or emails.
- Rotate after any incident or handover and update the password-manager entry (this file does not change on rotation).

> **Why this file changed.** During the 2026-07-07 incident (#218633) we tested with a real faculty member's login (`LindeeAbe`). On 2026-07-08 the client changed that password, which immediately broke our testing -- the exact fragility of borrowing a real person's account. We now use a **dedicated** test account that we own and control, and we no longer keep plaintext passwords in the repo. See "Retired accounts" below.

---

## ppetoolkit.com -- dedicated non-admin student (PROVISION THIS)

The canonical render test must run as an **enrolled, non-admin student**: admins bypass the access gate and cache and see content even when students get a blank page (root cause of #218633). An un-enrolled subscriber is NOT a valid test either -- it only ever sees the enrollment gate, so it looks "fine" while enrolled students are blank.

**Dedicated account spec** (create once, owned by us, never a real person):

| Field | Value |
|-------|-------|
| Username | `gd-qa-student` |
| Display name | `GD QA Student -- DO NOT DELETE` |
| Email | a mailbox we control, e.g. `qa+ppetoolkit@gorilladevops.com` |
| Role | Subscriber / student (non-admin, no editor capabilities) |
| Enrollment | Course **9659 "Live Lectures"** plus the same groups a real faculty student has, so it reaches gated topic/lesson content |
| Password | Team password manager entry: `ppetoolkit.com -- GD QA Student` |

**Provisioning checklist** (requires WordPress admin on ppetoolkit.com -- action item, not yet done):

- [ ] Create the user with the username/role above
- [ ] Set a strong password, stored ONLY in the password manager (entry name above)
- [ ] Enroll the user in course 9659 and the relevant groups
- [ ] Verify in incognito: open `/topic/cardiac-disorders/` -- the topic **body** renders (not just the title/sidebar)
- [ ] Confirm no admin/editor toolbar (the console check's Session row reads PASS, non-admin)
- [ ] Record the user ID here once created: `<TBD>`

Until this account exists, coordinate a temporary enrolled-student login with the client, treat it as short-lived, and store its password in the password manager, not here.

## ppemedical.com -- test customer (for checkout testing)

- Checkout can be tested as a **guest** or as a dedicated customer account.
- If a persistent account is wanted: create `gd-qa-customer` (Customer role), password in the password manager (`ppemedical.com -- GD QA Customer`).
- Use a **test-mode / sandbox** payment path for any real submission -- never a live card. The console check only confirms the checkout UI and payment gateways rendered; it does not submit.

## ppemedevents.com -- no login required

- Events are public; the console check runs logged out. No dedicated account needed unless event registration itself is being tested.

---

## Admin comparison account

For side-by-side "admin sees it, student does not" comparison only. The client's own admin (`robert.beatty@ppemedical.com`, user ID 5) is the site owner's personal login -- do **not** store its password here or use it for routine testing. Prefer our own admin access where available.

## Retired accounts (do not use)

| Account | Status | Reason |
|---------|--------|--------|
| `LindeeAbe` (faculty, enrolled) | **Retired** | Real faculty member's login, borrowed during #218633. Password changed by the client 2026-07-08. Replaced by the dedicated `gd-qa-student` account above. |
| `Rob Beatty` (subscriber, NOT enrolled) | **Do not use for render tests** | Real person's account, and un-enrolled -- only ever sees the enrollment gate, so it cannot validate topic-body rendering. |

---

## Related documents

- [Browser Console Regression Checks](../guides/browser-console-regression-checks.md)
- [Tests](../tests/README.md)
- [Regression Test Checklist: ppetoolkit.com](../checklists/regression-test-ppetoolkit-com.md)
- [Regression Test Automation Plan](../guides/regression-automation-plan.md)

---

*Last updated: 2026-07-14*
