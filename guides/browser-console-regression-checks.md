# Browser Console Regression Checks

**Last updated:** 2026-07-14
**Purpose:** Zero-install, read-only checks you paste into the Chrome DevTools console to verify a page in the browser session you are actually logged into. This is the "Tier 0" layer of the [Regression Test Automation Plan](regression-automation-plan.md). The runnable snippets live in [`tests/console/`](../tests/console/), one per site; this guide is the how-to.

---

## Why console checks

The 2026-07-07 incident (#218633) was invisible from an admin session and invisible to an HTTP-200 check: topic and lesson bodies were blank for enrolled non-admin students while admins saw everything. A console snippet runs inside whatever session the browser has, so if you paste it while logged in **as the enrolled student**, it checks that exact broken context -- no separate tooling, no login handling.

These checks are **read-only**. They inspect the current page and report; they do not submit forms, add to cart, place orders, or start/submit quizzes.

## Per-site test files

Each site has a different surface, so each has its own snippet:

| Site | File | Checks |
|------|------|--------|
| ppetoolkit.com | [`tests/console/ppetoolkit-console-checks.js`](../tests/console/ppetoolkit-console-checks.js) | Non-admin student render (#218633 catcher), Elementor CSS 404s, session/role, QBank quiz |
| ppemedical.com | [`tests/console/ppemedical-console-checks.js`](../tests/console/ppemedical-console-checks.js) | Checkout payment gateways (Authorize.Net), product/cart/account render, CSS 404s |
| ppemedevents.com | [`tests/console/ppemedevents-console-checks.js`](../tests/console/ppemedevents-console-checks.js) | Events Calendar list/month view and single-event render, CSS 404s |

## How to run

> **Use an incognito window.** Test in a fresh incognito/private window so you see the site as a real visitor. An admin or logged-in session bypasses caching and can render differently (this is the core #218633 lesson), and for ppemedical.com a clean session is the honest way to see the customer checkout. For ppetoolkit.com, log in **as the dedicated enrolled student inside that incognito window** -- not as your admin account.

1. Log in to the site **in the right role**. For ppetoolkit.com this MUST be the dedicated enrolled non-admin student (see [reference/test-accounts.md](../reference/test-accounts.md)); an admin session masks the bug. For ppemedical.com use a customer/guest; ppemedevents.com needs no login.
2. Navigate to a relevant page (see the "run it here" lists below).
3. Open DevTools: `Cmd+Option+J` (macOS) or `Ctrl+Shift+J` (Windows/Linux).
4. If the console shows a paste warning, type `allow pasting` and press Enter (Chrome self-XSS guard).
5. Open the site's `.js` file, copy the whole contents, paste into the Console, press Enter.
6. Read the printed summary table. Aim for `0 FAIL`. A red banner or a `FAIL` row tells you what to look at.

> **Only paste console scripts you trust and have reviewed.** These are maintained in this repo. Do not paste console code from clients, tickets, or the open web.

## Run it here (pages to check per site)

**ppetoolkit.com** -- as the enrolled student (`gd-qa-student`):

| Page | Example URL | Expect |
|------|-------------|--------|
| Topic (Elementor) | `/topic/cardiac-disorders/` | Content render PASS -- the page class that went blank on 07-07 |
| Topic (had missing CSS) | `/topic/cervical-spine-injuries/` | Content render PASS + Stylesheets PASS |
| Lesson | a page under `/lessons/...` | Content render PASS |
| Course | `/courses/live-lectures/` | Session non-admin, no CSS 404s |
| Quiz | a QBank quiz page | Quiz render PASS + Start button custom text |

**ppemedical.com** -- in an incognito window, as a guest/customer:

| Page | Example URL | Expect |
|------|-------------|--------|
| Shop | `/shop/` | Shop products PASS |
| Product | any single product | Add to Cart + price PASS, **Express checkout PASS** (Stripe + PayPal buttons render) |
| Cart | `/cart/` | Cart render PASS |
| Checkout | `/checkout/` | Payment gateways PASS (Authorize.Net present) + Place Order PASS |
| My Account | `/my-account/` | My Account render PASS |

> **Express checkout is only half-testable from the console.** The Stripe (Apple Pay / Google Pay / Link) and PayPal buttons render inside cross-origin iframes, so the console check confirms they *rendered* but cannot click them. After a PASS, manually **click each express checkout button in incognito** and confirm it opens the correct checkout flow. Wallet buttons (Apple Pay / Google Pay) only appear on a browser/device that has that wallet, so a WARN can mean "no wallet here" rather than "broken" -- verify on a real device. This click-through is a Phase 2 Playwright candidate.

**ppemedevents.com** -- logged out is fine:

| Page | Example URL | Expect |
|------|-------------|--------|
| Events list / calendar | `/events/` | Events view PASS |
| Single event | any event page | Event title PASS + schedule/venue |

## Reading the result

- **FAIL on Content render (ppetoolkit)** -- the page is blank for this user. If you are the enrolled student, this is the #218633 class of failure: escalate, check the LearnDash 5.1.4 pin, and clear caches.
- **FAIL on Checkout payment (ppemedical)** -- no payment gateways rendered: payment is down. Do not go live; escalate.
- **FAIL on Stylesheets** -- a CSS file 404'd. On ppetoolkit that means blank content; regenerate Elementor CSS and clear both caches (checklist Section 0).
- **WARN on Session (ppetoolkit)** -- you are probably testing as an admin. Stop and re-test as the enrolled student, or the result means nothing. A red banner says the same thing loudly.

## Extra snippets (any site)

### Session / role context only

Quick confirmation you are in the right test context before you trust anything else.

```javascript
(() => {
  const loggedIn = document.body.classList.contains('logged-in');
  const editTools = !!document.querySelector('#wp-admin-bar-edit, #wp-admin-bar-new_content, [id^="wp-admin-bar-edit_with_elementor"], .elementor-edit-link');
  console.log('logged in:', loggedIn, '| editor/admin tools visible:', editTools);
  console.log(editTools
    ? '%cLikely an ADMIN session -- this masks the #218633 bug. Re-test as the enrolled student.'
    : '%cLooks like a non-admin session -- good for render testing.',
    'font-weight:bold;color:' + (editTools ? '#c00' : '#080'));
})();
```

### Interaction error watcher (paste first, then click around)

The console cannot retrieve errors that fired before it opened. Paste this, then interact with the page (start a quiz, navigate lessons, step through checkout); collected errors print live and accumulate in `window.__ppeErrors`.

```javascript
(() => {
  if (window.__ppeErrHook) { console.log('Error watcher already installed. Read window.__ppeErrors.'); return; }
  window.__ppeErrHook = true;
  window.__ppeErrors = [];
  addEventListener('error', (e) => {
    window.__ppeErrors.push(e.message + ' @ ' + (e.filename || '') + ':' + (e.lineno || ''));
    console.warn('[PPE] JS error:', e.message);
  });
  addEventListener('unhandledrejection', (e) => {
    const r = (e.reason && e.reason.message) || e.reason;
    window.__ppeErrors.push('promise: ' + r);
    console.warn('[PPE] Promise rejection:', r);
  });
  console.log('%c[PPE] Error watcher installed. Interact with the page, then run: window.__ppeErrors', 'color:#080;font-weight:bold');
})();
```

---

## Notes and limitations

- **Selectors and thresholds are a starting point.** The content-render heuristic (empty region = under 400 chars, no widgets, no media) and the site-specific selectors were written from the #218633 evidence and standard WooCommerce / Events Calendar markup, not by inspecting every template. Validate against a known-good page on first use and adjust the selectors in the site's `.js` file if a good page is misflagged. The Tier-1 Playwright suite will reuse the same selectors.
- **Cross-origin assets report `responseStatus` 0** and are intentionally skipped, so a CDN font or script will not show as a false 404. The site-origin CSS files that matter report a real status.
- **These do not replace the manual checklist or the Playwright suite.** They are the fastest first look during hands-on testing. The authoritative record stays the [checklists](../checklists/).

## Related documents

- [Tests](../tests/README.md)
- [Regression Test Automation Plan](regression-automation-plan.md)
- [Test Accounts](../reference/test-accounts.md)
- [Regression Test Checklist: ppetoolkit.com](../checklists/regression-test-ppetoolkit-com.md)
- [Visual Regression Testing Guide](visual-regression-testing-guide.md)

---

*Last updated: 2026-07-14*
