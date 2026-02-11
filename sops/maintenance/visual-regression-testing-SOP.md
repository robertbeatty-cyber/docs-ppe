# SOP: Visual Regression Testing with BackstopJS

**Version:** 1.0
**Date:** 2026-02-11
**Status:** Active
**Last updated:** 2026-02-11
**Last reviewed by:** Technical Lead
**Applies to:** Maintenance Technician
**Purpose:** Install, configure, and run BackstopJS visual regression tests against PPE Medical websites during staged update cycles

---

## Prerequisites

✅ You have Node.js version 16 or higher installed (`node --version` to check)
✅ You have npm installed (comes with Node.js -- `npm --version` to check)
✅ You have cloned this repository locally
✅ You have internet access to reach the production and staging sites
✅ You are familiar with the [Staged Website Updates SOP](staged-website-updates-SOP.md) (this SOP covers Step 5 of that workflow)

---

## What is This SOP?

This SOP provides step-by-step instructions for installing BackstopJS, configuring it for PPE Medical's three websites, and running visual regression tests during monthly update cycles. Visual regression testing captures screenshots of production pages (before updates) and staging pages (after updates), then generates a comparison report highlighting any unintended visual changes.

This is a one-time setup (Steps 1-3) followed by a repeatable test workflow (Steps 4-7) run each update cycle.

---

## Roles & Responsibilities

### Maintenance Technician
- Performs the one-time installation and configuration
- Runs visual regression tests during each update cycle
- Reviews reports and escalates unexpected visual regressions

### Technical Lead (Escalation)
- Assists with troubleshooting installation issues
- Reviews flagged visual regressions if the Maintenance Technician is unsure whether they are acceptable

---

## Process Workflow

### Step 1 - Install Node.js and BackstopJS (One-Time)

1. **Check if Node.js is installed:**
   ```bash
   node --version
   ```
   - If the output shows v16.x or higher, proceed to sub-step 3
   - If Node.js is not installed or the version is below 16, proceed to sub-step 2

2. **Install Node.js** (if needed):
   - Go to https://nodejs.org/
   - Download the LTS (Long Term Support) version
   - Run the installer and follow the prompts
   - Close and reopen your terminal after installation
   - **Verify:** Run `node --version` -- it should show v16.x or higher

3. **Install BackstopJS globally:**
   ```bash
   npm install -g backstopjs
   ```

4. **Verify BackstopJS is installed:**
   ```bash
   backstop --version
   ```
   - **Verify:** The command outputs a version number (e.g., `6.x.x`)

**Outcome:** Node.js and BackstopJS are installed and available in your terminal.

---

### Step 2 - Initialize BackstopJS in the Repository (One-Time)

1. **Open your terminal and navigate to the repository root:**
   ```bash
   cd path/to/docs-ppe
   ```

2. **Initialize BackstopJS:**
   ```bash
   backstop init
   ```
   This creates:
   - `backstop.json` -- the main configuration file
   - `backstop_data/` -- directory for screenshots, reports, and engine scripts

3. **Verify the files were created:**
   ```bash
   ls backstop.json backstop_data/
   ```
   - **Verify:** `backstop.json` exists and the `backstop_data/` directory contains subdirectories

4. **Confirm `backstop_data/` is in `.gitignore`:**
   ```bash
   grep "backstop_data" .gitignore
   ```
   - **Verify:** Output shows `backstop_data/`
   - If not found, add `backstop_data/` to `.gitignore`

**Outcome:** BackstopJS is initialized with default configuration files in the repository.

---

### Step 3 - Configure BackstopJS for PPE Medical Sites (One-Time)

1. **Open `backstop.json` in your editor**

2. **Replace the entire contents** with the following configuration:

```json
{
  "id": "ppe-medical",
  "viewports": [
    {
      "label": "desktop",
      "width": 1920,
      "height": 1080
    },
    {
      "label": "tablet",
      "width": 768,
      "height": 1024
    },
    {
      "label": "mobile",
      "width": 375,
      "height": 812
    }
  ],
  "scenarios": [
    {
      "label": "ppemedevents - Homepage",
      "url": "https://staging.ppemedevents.com/",
      "referenceUrl": "https://ppemedevents.com/",
      "delay": 3000,
      "misMatchThreshold": 0.5,
      "removeSelectors": [".cookie-notice", ".popup-overlay"]
    },
    {
      "label": "ppemedevents - Events Calendar",
      "url": "https://staging.ppemedevents.com/events/",
      "referenceUrl": "https://ppemedevents.com/events/",
      "delay": 3000,
      "misMatchThreshold": 1.0,
      "removeSelectors": [".cookie-notice", ".popup-overlay"]
    },
    {
      "label": "ppemedical - Homepage",
      "url": "https://staging.ppemedical.com/",
      "referenceUrl": "https://ppemedical.com/",
      "delay": 3000,
      "misMatchThreshold": 0.5,
      "removeSelectors": [".cookie-notice", ".popup-overlay"]
    },
    {
      "label": "ppemedical - Shop",
      "url": "https://staging.ppemedical.com/shop/",
      "referenceUrl": "https://ppemedical.com/shop/",
      "delay": 3000,
      "misMatchThreshold": 0.5
    },
    {
      "label": "ppemedical - Cart",
      "url": "https://staging.ppemedical.com/cart/",
      "referenceUrl": "https://ppemedical.com/cart/",
      "delay": 3000,
      "misMatchThreshold": 1.0
    },
    {
      "label": "ppemedical - Checkout",
      "url": "https://staging.ppemedical.com/checkout/",
      "referenceUrl": "https://ppemedical.com/checkout/",
      "delay": 3000,
      "misMatchThreshold": 1.0
    },
    {
      "label": "ppetoolkit - Homepage",
      "url": "https://staging.ppetoolkit.com/",
      "referenceUrl": "https://ppetoolkit.com/",
      "delay": 3000,
      "misMatchThreshold": 0.5,
      "removeSelectors": [".cookie-notice", ".popup-overlay"]
    },
    {
      "label": "ppetoolkit - Course Listing",
      "url": "https://staging.ppetoolkit.com/courses/",
      "referenceUrl": "https://ppetoolkit.com/courses/",
      "delay": 3000,
      "misMatchThreshold": 0.5
    },
    {
      "label": "ppetoolkit - Login Page",
      "url": "https://staging.ppetoolkit.com/wp-login.php",
      "referenceUrl": "https://ppetoolkit.com/wp-login.php",
      "delay": 3000,
      "misMatchThreshold": 0.5
    }
  ],
  "paths": {
    "bitmaps_reference": "backstop_data/bitmaps_reference",
    "bitmaps_test": "backstop_data/bitmaps_test",
    "engine_scripts": "backstop_data/engine_scripts",
    "html_report": "backstop_data/html_report",
    "ci_report": "backstop_data/ci_report"
  },
  "engine": "puppeteer",
  "engineOptions": {
    "args": ["--no-sandbox"]
  },
  "asyncCaptureLimit": 3,
  "asyncCompareLimit": 10,
  "debug": false,
  "debugWindow": false,
  "misMatchThreshold": 0.1
}
```

3. **Save the file**

4. **Run a quick test** to verify the configuration works:
   ```bash
   backstop reference
   ```
   - This will capture reference screenshots from the production sites
   - Wait for it to complete (may take 1-2 minutes depending on connection speed)
   - **Verify:** Terminal output shows "reference screenshots captured" with no errors
   - **Verify:** Run `ls backstop_data/bitmaps_reference/` -- screenshot files should exist

**Outcome:** BackstopJS is configured with scenarios for all three PPE Medical sites and has captured an initial set of reference screenshots.

---

### Step 4 - Capture Reference Screenshots (Each Update Cycle)

> **When:** Run this at the beginning of each update cycle, BEFORE syncing production to staging.

1. **Navigate to the repository root:**
   ```bash
   cd path/to/docs-ppe
   ```

2. **Capture reference screenshots from production:**
   ```bash
   backstop reference
   ```

3. **Wait for the capture to complete.** BackstopJS will:
   - Open a headless browser
   - Navigate to each production URL listed in the scenarios
   - Capture screenshots at all three viewport sizes (desktop, tablet, mobile)
   - Save screenshots to `backstop_data/bitmaps_reference/`

4. **Verify:** Check the terminal output for errors
   - If a specific page fails to load, check the URL is correct and accessible
   - If all pages fail, check your internet connection

**Outcome:** Fresh reference screenshots of all production pages are captured.

---

### Step 5 - Run Test Against Staging (Each Update Cycle)

> **When:** Run this AFTER updates have been applied on staging (Staged Website Updates SOP, Step 3 complete).

1. **Confirm staging sites are updated and caches are cleared**

2. **Run the test:**
   ```bash
   backstop test
   ```

3. **Wait for the test to complete.** BackstopJS will:
   - Open a headless browser
   - Navigate to each staging URL listed in the scenarios
   - Capture screenshots at all three viewport sizes
   - Compare each staging screenshot against the corresponding reference screenshot
   - Generate an HTML comparison report

4. **Verify:** Check the terminal output for the pass/fail summary
   - Passed scenarios: no visual differences beyond the threshold
   - Failed scenarios: visual differences detected -- needs review

**Outcome:** Test screenshots captured and comparison report generated.

---

### Step 6 - Review the Comparison Report (Each Update Cycle)

1. **Open the HTML report:**
   ```bash
   backstop openReport
   ```
   This opens the report in your default browser.

2. **Understand the report layout:**

   | Color | Meaning |
   |-------|---------|
   | Green | Scenario passed -- no visual differences beyond threshold |
   | Red/Pink | Scenario failed -- visual differences detected |

3. **For each failed scenario, review the three panels:**
   - **Reference:** Screenshot from production (before updates)
   - **Test:** Screenshot from staging (after updates)
   - **Diff:** Pink/magenta overlay highlighting exactly where changes occurred

4. **Evaluate each difference:**

   | Type of Difference | Action |
   |--------------------|--------|
   | Dynamic content (dates, timestamps, counters) | Acceptable -- ignore |
   | New content added by the client | Acceptable -- ignore |
   | Minor rendering differences (anti-aliasing, font smoothing) | Acceptable -- ignore |
   | Broken layout (shifted sections, overlapping elements) | Investigate -- do not proceed |
   | Missing images or icons | Investigate -- do not proceed |
   | Missing navigation items or buttons | Investigate -- do not proceed |
   | Blank page or error page | **Critical** -- stop and escalate |

5. **If all differences are acceptable:** Proceed to the next step in the Staged Website Updates SOP

6. **If unexpected visual regressions are found:**
   - Take note of which pages and elements are affected
   - Check if the issue is related to a specific plugin update
   - If you can identify the cause, consider rolling back that specific plugin on staging and retesting
   - If unsure, escalate to the Technical Lead with screenshots from the report

**Outcome:** All visual differences reviewed and classified as acceptable or escalated.

---

### Step 7 - Approve Reference for Next Cycle (Optional)

If the staging screenshots represent the new expected state (e.g., after intentional design changes), you can approve them as the new reference:

```bash
backstop approve
```

This copies the test screenshots to become the new reference screenshots. Only do this when the visual changes are intentional and verified.

**Outcome:** Reference screenshots updated for the next cycle.

---

## Adding New Pages to Test

As the sites evolve, you may need to add new pages to the visual regression test.

1. **Open `backstop.json`**

2. **Add a new scenario** to the `scenarios` array:

```json
{
  "label": "[site] - [Page Name]",
  "url": "https://staging.[site].com/[page-path]/",
  "referenceUrl": "https://[site].com/[page-path]/",
  "delay": 3000,
  "misMatchThreshold": 0.5
}
```

3. **Choose the right settings:**
   - `delay`: Use `3000` for simple pages, `5000` for heavy pages (Elementor, LearnDash)
   - `misMatchThreshold`: Use `0.5` for static pages, `1.0` for dynamic pages (calendars, carts)
   - `removeSelectors`: Add CSS selectors for elements that change on every load (cookie banners, popups, chat widgets)
   - `hideSelectors`: Add CSS selectors for elements to hide but preserve their space in the layout

4. **Run `backstop reference`** to capture the new page's baseline

---

## Testing Authenticated Pages (ppetoolkit.com)

Some pages on ppetoolkit.com require a logged-in user (course content, quizzes, student dashboard).

### Cookie Injection Method

1. **Log into ppetoolkit.com** in your browser using a test account

2. **Open browser DevTools** (F12) > **Application** tab > **Cookies**

3. **Find the `wordpress_logged_in_*` cookie** and copy its name and value

4. **Create the cookie file** at `backstop_data/cookies/ppetoolkit.json`:

```json
[
  {
    "domain": ".ppetoolkit.com",
    "path": "/",
    "name": "wordpress_logged_in_HASH",
    "value": "YOUR_COOKIE_VALUE",
    "expirationDate": 1893456000,
    "hostOnly": false,
    "httpOnly": false,
    "secure": false,
    "session": false,
    "sameSite": "no_restriction"
  }
]
```

5. **Replace** `HASH` with the actual hash from the cookie name and `YOUR_COOKIE_VALUE` with the actual value

6. **Add authenticated scenarios** to `backstop.json`:

```json
{
  "label": "ppetoolkit - Student Dashboard (Authenticated)",
  "url": "https://staging.ppetoolkit.com/dashboard/",
  "referenceUrl": "https://ppetoolkit.com/dashboard/",
  "delay": 5000,
  "cookiePath": "backstop_data/cookies/ppetoolkit.json",
  "misMatchThreshold": 0.5
}
```

> **Important:** Cookies expire. You will need to refresh the cookie file before each update cycle. Never commit cookie files to the repository.

7. **Add the cookie file to `.gitignore`:**
   ```
   backstop_data/cookies/
   ```

**Outcome:** Authenticated pages are included in visual regression tests.

---

## Common Mistakes & How to Avoid Them

❌ **Mistake:** Running `backstop test` without running `backstop reference` first
✅ **Correct approach:** Always capture fresh reference screenshots from production before running tests against staging

❌ **Mistake:** Using stale reference screenshots from a previous update cycle
✅ **Correct approach:** Run `backstop reference` at the start of each update cycle, right before making any changes

❌ **Mistake:** Panicking over failed scenarios without reviewing the actual diffs
✅ **Correct approach:** Open the report, review each diff. Most failures are dynamic content (dates, timestamps) and are acceptable

❌ **Mistake:** Using a very strict `misMatchThreshold` (0.1) for dynamic pages
✅ **Correct approach:** Use `1.0` or higher for pages with dynamic content like event calendars, shopping carts, or countdowns

❌ **Mistake:** Not clearing caches on staging before running `backstop test`
✅ **Correct approach:** Always clear MyKinsta caches on staging after applying updates and before running the test

❌ **Mistake:** Committing `backstop_data/` to the repository
✅ **Correct approach:** Keep `backstop_data/` in `.gitignore`. Screenshots are large binary files that do not belong in version control

---

## Troubleshooting

### BackstopJS command not found

```
bash: backstop: command not found
```

**Fix:** Reinstall globally with `npm install -g backstopjs`. If using nvm, make sure you are in the correct Node.js version.

### Puppeteer fails to launch browser

```
Error: Failed to launch the browser process
```

**Fix:** Run `npx puppeteer browsers install chrome` to download the browser binary. On macOS, you may need to allow it through System Preferences > Privacy & Security.

### Screenshots are blank or show error pages

**Possible causes:**
- The staging site URL is wrong -- verify in `backstop.json`
- The staging site is password-protected -- disable "Password Protected" plugin on staging or add the cookie
- The staging site is down -- check MyKinsta for environment status
- Network issues -- verify you can reach the URL in your browser

### All scenarios fail with high mismatch

**Possible causes:**
- Reference screenshots are from a different date/content state -- re-run `backstop reference`
- A major layout change was made -- review diffs, if intentional run `backstop approve`
- Cookie banners or popups are showing on one environment but not the other -- add them to `removeSelectors`

### Test runs very slowly

**Fix:** Reduce `asyncCaptureLimit` in `backstop.json` to `1` or `2` if your machine has limited resources. Increase `delay` values if pages are not fully loading before capture.

---

## Verification Checklist

### One-Time Setup

- [ ] Node.js v16+ is installed
- [ ] BackstopJS is installed globally (`backstop --version` works)
- [ ] `backstop init` has been run in the repository root
- [ ] `backstop.json` contains scenarios for all three sites
- [ ] `backstop_data/` is in `.gitignore`
- [ ] `backstop reference` runs successfully and captures screenshots

### Each Update Cycle

- [ ] Fresh reference screenshots captured from production (`backstop reference`)
- [ ] Updates applied on staging and caches cleared
- [ ] Test screenshots captured from staging (`backstop test`)
- [ ] HTML report reviewed (`backstop openReport`)
- [ ] All visual differences classified as acceptable or escalated
- [ ] No unexpected layout breaks, missing elements, or broken pages

---

## Related Documents

- [Staged Website Updates SOP](staged-website-updates-SOP.md) -- this SOP covers Step 5 of that workflow
- [Visual Regression Testing Guide](../../guides/visual-regression-testing-guide.md) -- reference guide with additional configuration details, alternative tools, and advanced topics
- [Regression Test Checklist: ppemedical.com](../../checklists/regression-test-ppemedical-com.md)
- [Regression Test Checklist: ppetoolkit.com](../../checklists/regression-test-ppetoolkit-com.md)
- [Regression Test Checklist: ppemedevents.com](../../checklists/regression-test-ppemedevents-com.md)

---

*Last reviewed: 2026-02-11*
*Next review: 2026-05-11 (Quarterly)*

---

*This SOP is part of the PPE Medical documentation repository.*
