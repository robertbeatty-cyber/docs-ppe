# End-to-End Tests (Playwright) -- Phase 2

**Last updated:** 2026-07-14
**Status:** Placeholder. Not yet built.

This directory will hold the **Tier 1** Playwright suite described in the [Regression Test Automation Plan](../../guides/regression-automation-plan.md): headless, unattended browser tests that run against staging (and read-only smoke against production) after every update round.

Unlike the Tier 0 console checks in [`../console/`](../console/) -- which a technician pastes by hand into a session they are already logged into -- the Playwright suite handles its own authenticated sessions and can drive multi-step flows (a full non-admin student render sweep, a QBank quiz attempt, a WooCommerce test-mode checkout on staging).

## Agreed scope (from the plan)

- **Home:** this repo, under `tests/` (decision D1).
- **Secrets:** credentials injected via environment variables sourced from the team password manager at run time; nothing secret committed (decision D2). See [reference/test-accounts.md](../../reference/test-accounts.md).
- **Trigger:** manual-run only for Phase 2; CI/schedule deferred (decision D3).
- **Prod safety:** production runs are strictly read-only smoke; state-changing tests (quiz submission, test checkout) run on staging only (decision D4).

## First tests to build (Phase 2)

1. `ppetoolkit` non-admin render sweep -- log in as the dedicated student, assert topic/lesson bodies render (not just HTTP 200), assert no Elementor CSS 404s.
2. `ppetoolkit` QBank quiz smoke -- start to submit to score, on staging.
3. `ppemedical` express checkout click-through -- click each product-page express button (Stripe / PayPal) and assert it opens the correct checkout flow. The console check only confirms the buttons rendered; clicking through the cross-origin wallet iframe needs Playwright (and, for wallet buttons, a test wallet on the runner).
4. WP-CLI health/pin check -- LearnDash held at 5.1.4, mu-plugin update-lock present, no new PHP fatals.

The console checks in `../console/` are the reference for the selectors and assertions these tests will reuse.
