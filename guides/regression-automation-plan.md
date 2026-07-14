# Regression Test Automation Plan

**Last updated:** 2026-07-14
**Purpose:** Define which per-site regression checks to automate, how, and in what order -- so automation front-loads the mechanical checks while the manual checklists stay authoritative. Decisions are agreed (see below); the Tier 0 console checks are built, Tier 1 is Phase 2.

---

## Why this exists

Incident #218633 (2026-07-07, ppetoolkit.com) exposed a gap the manual process could not reliably close: course topic and lesson bodies rendered blank for every enrolled non-admin student while admins saw everything, caused by a LearnDash 5.1.6 regression and unmasked by a routine cache clear. The failure was invisible from an admin session and invisible to an HTTP-200 check. See the checklist warnings in [regression-test-ppetoolkit-com.md](../checklists/regression-test-ppetoolkit-com.md) and the test accounts in [reference/test-accounts.md](../reference/test-accounts.md).

The lesson drives the whole design: **automation must log in as an enrolled non-admin student and assert that rendered content is present, not merely that the page returns 200.**

## Scope and non-goals

- **In scope:** the mechanical, assertable checks across the three sites' regression checklists -- the roughly 60% that a machine can verify unambiguously.
- **Not a replacement:** the manual checklists remain the authoritative record. Automation produces a pass/fail summary the technician pastes in; it does not delete a single checklist item.
- **Out of scope for now:** visual/subjective checks, real payment and email side effects, and full visual-regression snapshots (already covered separately by [visual-regression-testing-guide.md](visual-regression-testing-guide.md)).

## Design principles

1. **Assert content, not status codes.** A check passes only when the expected rendered element or body text is present. HTTP 200 alone is treated as a failure signal, not a pass.
2. **Test as an enrolled non-admin student.** Admin sessions bypass access, progression, and cache and are misleading. Use the canonical enrolled student account, never an un-enrolled subscriber (which only ever sees the enrollment gate and looks "fine").
3. **Staging first, prod read-only.** Destructive or state-changing steps run on staging. Prod runs are read-only smoke checks only.
4. **Runs after ANY update, not just the monthly cycle.** Out-of-cycle security rounds are the exact window that triggered #218633.
5. **No secrets in code.** Credentials come from the environment or the team password manager, never hardcoded. See decision D2.

## Tiering

### Tier 0 -- zero-install console checks (available now)

Read-only JavaScript snippets pasted into the Chrome DevTools console, run by hand in the browser session the technician is already logged into. Because they run in the live session, pasting them while logged in as the enrolled student checks the exact context that hid #218633, with no tooling. They cover non-admin render, CSS 404s, session/role, and quiz presence, and are the fastest first look during a post-update pass. The same selectors and assertions are promoted into the Tier-1 Playwright suite. See [Browser Console Regression Checks](browser-console-regression-checks.md).

### Tier 1 -- automate first (high value, unattended)

| Automated check | Method | Maps to checklist section | Catches |
|---|---|---|---|
| Non-admin student render of course, lesson, and topic -- assert body present | Playwright headless, enrolled student session | ppetoolkit S0, S2, S7 | #218633 exactly |
| No CSS/JS 404s on those pages (`post-<ID>.css`, `custom-frontend.min.css`) | Playwright network interception | ppetoolkit S0, S7 | 07-07 asset symptom |
| Full quiz attempt start to submit to score, as a student | Playwright | ppetoolkit S3, S12 | QBank / LearnDash version breakage |
| PHP error-log delta after update | WP-CLI + log grep over SSH | ppetoolkit S4, S12 | New fatals |
| Plugin version and active-state assertions; LearnDash pinned at 5.1.4; mu-plugin update-lock present | `wp plugin list` parse | ppetoolkit S12, version table | Accidental un-pin, deactivated QBank |
| Homepage, nav, and key pages load with no console errors | Playwright | ppetoolkit S1 | Gross breakage |

### Tier 2 -- automate selectively (lower value)

Admin "settings page loads without errors" checks (Sections 9 to 11). Automate only the few with real consequences: NinjaFirewall enabled, LightStart maintenance-mode OFF, WP Mail SMTP connected. Skip the rest -- high selector-maintenance cost for a weak signal.

### Tier 3 -- stays manual

- Visual and subjective checks: "no broken layouts", "displays correctly", mobile responsive.
- Real-world side effects: payment processing, live notification emails, certificate PDF content.
- One-off config confirmations and the Elementor editor loading in admin.

## Proposed toolchain and layout

- **Playwright (headless Chromium)** for browser-context checks. Chosen for reliable authenticated sessions, network interception (the 404 check), and DOM assertions.
- **WP-CLI over SSH** for server-side health, version, and pin checks.
- Home in the top-level `tests/` tree (Tier 0 already built):

```
tests/
├── README.md
├── console/                      (Tier 0 -- built: per-site paste-in-console checks)
│   ├── ppetoolkit-console-checks.js
│   ├── ppemedical-console-checks.js
│   └── ppemedevents-console-checks.js
└── e2e/                          (Tier 1 -- Phase 2: Playwright)
    ├── ppetoolkit.spec.*         (non-admin render, CSS-404, quiz smoke)
    └── wp-health/                (WP-CLI version + pin + error-log checks)
```

- **Where it runs:** on demand from a maintenance workstation, and after every update round including out-of-cycle security rounds. CI/scheduled runs are a later phase (decision D3).
- **Output:** a concise pass/fail summary the technician copies into the relevant checklist. The manual checklist remains the signed record.

## Rollout phases

1. **Phase 1 (done):** scope agreed, decisions D1-D4 settled, Tier 0 console checks built.
2. **Phase 2:** scaffold the ppetoolkit Tier-1 suite -- non-admin render, CSS-404, quiz smoke, plus the WP-CLI health/pin check. Prove it catches a simulated #218633 on staging.
3. **Phase 3:** generalize to ppemedical.com and ppemedevents.com (add their non-admin render and key-flow smoke checks).
4. **Phase 4:** add the selective Tier-2 checks and, if wanted, scheduled runs.

## Decisions (agreed 2026-07-14)

- **D1 -- Home for the code.** Automation lives in this repo under a top-level `tests/` folder (`tests/console/` for the Tier 0 console checks, `tests/e2e/` for the Tier 1 Playwright suite). This keeps the checklists, automation, and test-account references together. See [tests/README.md](../tests/README.md).
- **D2 -- Secrets handling.** Credentials are injected via environment variables sourced from the team password manager at run time. `reference/test-accounts.md` becomes a pointer to the password-manager entry, not a credential store. No secrets are committed.
- **D3 -- Run trigger.** Manual-run only for Phase 2, on demand after any update round. CI / scheduled runs are deferred to Phase 4 once the suite is trusted.
- **D4 -- Prod safety boundary.** Prod runs are strictly read-only smoke checks. The full quiz-attempt (state-changing) test runs on staging only; no bot-generated quiz attempts touch live student data.

## Related documents

- [Regression Test Checklist: ppetoolkit.com](../checklists/regression-test-ppetoolkit-com.md)
- [Test Accounts -- ppetoolkit.com](../reference/test-accounts.md)
- [Visual Regression Testing Guide](visual-regression-testing-guide.md)
- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)

---

*Last updated: 2026-07-14*
