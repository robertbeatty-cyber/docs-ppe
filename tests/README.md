# Tests

**Last updated:** 2026-07-14
**Purpose:** Automated regression tests for the three PPE Medical websites, run after WordPress and plugin updates. This complements the manual [checklists](../checklists/) and the [visual regression testing guide](../guides/visual-regression-testing-guide.md); it does not replace them.

See the [Regression Test Automation Plan](../guides/regression-automation-plan.md) for scope, tiering, and design decisions.

---

## Layout

```
tests/
├── README.md                             (this file)
├── console/                              (Tier 0: zero-install, paste into Chrome DevTools console)
│   ├── ppetoolkit-console-checks.js       LearnDash / QBank / Elementor render + CSS-404 + quiz
│   ├── ppemedical-console-checks.js       WooCommerce shop / product / cart / checkout gateways
│   └── ppemedevents-console-checks.js     The Events Calendar listing + single-event render
└── e2e/                                  (Tier 1: Playwright end-to-end -- see e2e/README.md, Phase 2)
    └── README.md
```

Each site has its **own** console test because each site has a different surface and different failure modes:

| Site | Test file | Focus |
|------|-----------|-------|
| ppetoolkit.com | `console/ppetoolkit-console-checks.js` | Non-admin student render (the #218633 blank-content catcher), Elementor CSS 404s, QBank quiz |
| ppemedical.com | `console/ppemedical-console-checks.js` | Checkout renders payment gateways (Authorize.Net), product/cart/account render |
| ppemedevents.com | `console/ppemedevents-console-checks.js` | Events Calendar list/month view and single-event render |

## Running the console tests

1. Open Chrome and log in to the site **in the right role** (for ppetoolkit.com this MUST be the dedicated enrolled non-admin student -- see [reference/test-accounts.md](../reference/test-accounts.md); an admin session masks the render bug).
2. Navigate to a relevant page (each file's header lists the pages it checks).
3. Open DevTools: `Cmd+Option+J` (macOS) or `Ctrl+Shift+J` (Windows/Linux).
4. If prompted, type `allow pasting` and press Enter (Chrome self-XSS guard).
5. Open the site's `.js` file, copy the whole contents, paste into the Console, press Enter.
6. Read the printed summary table: aim for `0 FAIL`. A red banner or a `FAIL` row tells you what to look at.

The step-by-step methodology, result interpretation, and the per-site "run it here" page lists are in the guide: [Browser Console Regression Checks](../guides/browser-console-regression-checks.md).

## Conventions

- **Read-only.** Console tests inspect the current page and report. They never submit a form, add to cart, place an order, or start/submit a quiz. Real transactions (test-mode checkout, full quiz attempt) are done manually per the checklist, or on staging via the Tier-1 suite.
- **Self-contained.** Each `.js` file is a single paste-able IIFE with no imports, so it works by copy-paste with no build step.
- **Assert content, not status codes.** A check passes only when the expected rendered element or text is present. HTTP 200 alone is never treated as a pass (this is the core lesson of incident #218633).
- **Credentials never live in this folder.** Test logins are documented in [reference/test-accounts.md](../reference/test-accounts.md); the passwords themselves live in the team password manager.

## Related documents

- [Regression Test Automation Plan](../guides/regression-automation-plan.md)
- [Browser Console Regression Checks](../guides/browser-console-regression-checks.md)
- [Regression test checklists](../checklists/)
- [Test Accounts](../reference/test-accounts.md)
- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
