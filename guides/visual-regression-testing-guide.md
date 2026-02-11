# Visual Regression Testing Guide

**Last updated:** 2026-02-11
**Purpose:** Set up and run visual regression tests for PPE Medical websites using BackstopJS

---

## What is Visual Regression Testing?

Visual regression testing automatically compares screenshots of web pages before and after changes (such as plugin updates) to detect unintended visual differences. Instead of manually checking every page, the tool captures screenshots of key pages on the production site (reference), then captures the same pages on the staging site (test), and generates a report highlighting any visual differences.

**Why use it:**
- Catches layout breaks, missing elements, and styling regressions that manual testing might miss
- Provides screenshot evidence of changes
- Reduces time spent manually checking pages
- Particularly valuable for sites with many pages built with Elementor

---

## Tool: BackstopJS

**BackstopJS** is a free, open-source visual regression testing tool that runs locally. It uses headless Chrome (via Puppeteer) to capture screenshots and generates an HTML comparison report.

**Why BackstopJS:**
- Free and open-source
- Runs locally (no cloud service needed)
- CLI-based (easy to integrate into workflows)
- Supports multiple viewports (desktop, tablet, mobile)
- Generates clear HTML diff reports
- Active community and good documentation

---

## Installation

### Prerequisites

- Node.js (version 16 or higher)
- npm (comes with Node.js)

### Install BackstopJS

```bash
# Install globally
npm install -g backstopjs

# Verify installation
backstop --version
```

---

## Configuration

### Initialize BackstopJS

Run this once in the repository root to create the configuration file:

```bash
cd path/to/docs-ppe
backstop init
```

This creates a `backstop.json` file and a `backstop_data/` directory.

### Configuration File

Replace the generated `backstop.json` with this configuration tailored to PPE Medical's sites:

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
  "scenarios": [],
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

### Site-Specific Scenario Files

Create separate scenario files for each site. This keeps configurations manageable.

#### ppemedevents.com Scenarios

```json
{
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
      "label": "ppemedevents - Single Event",
      "url": "https://staging.ppemedevents.com/events/",
      "referenceUrl": "https://ppemedevents.com/events/",
      "delay": 3000,
      "selectors": [".tribe-events-single"],
      "misMatchThreshold": 0.5
    }
  ]
}
```

#### ppemedical.com Scenarios

```json
{
  "scenarios": [
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
      "label": "ppemedical - Product Page",
      "url": "https://staging.ppemedical.com/shop/",
      "referenceUrl": "https://ppemedical.com/shop/",
      "delay": 3000,
      "selectors": [".product"],
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
    }
  ]
}
```

#### ppetoolkit.com Scenarios

```json
{
  "scenarios": [
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
  ]
}
```

> **Note:** Pages behind login (courses, quizzes, dashboards) require authentication handling. See the Authentication section below.

---

## Handling Authentication (ppetoolkit.com)

Some pages on ppetoolkit.com require a logged-in user (course content, quizzes, student dashboard). BackstopJS supports cookie injection for this.

### Option 1: Cookie Injection

1. Log into ppetoolkit.com in your browser
2. Open browser DevTools > Application > Cookies
3. Copy the `wordpress_logged_in_*` cookie name and value
4. Add to your scenario:

```json
{
  "label": "ppetoolkit - Course Content (Authenticated)",
  "url": "https://staging.ppetoolkit.com/courses/example-course/",
  "referenceUrl": "https://ppetoolkit.com/courses/example-course/",
  "delay": 5000,
  "cookiePath": "backstop_data/cookies/ppetoolkit.json",
  "misMatchThreshold": 0.5
}
```

Create `backstop_data/cookies/ppetoolkit.json`:

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

### Option 2: Engine Script (Puppeteer Login)

Create `backstop_data/engine_scripts/login-ppetoolkit.js`:

```javascript
module.exports = async (page, scenario, viewport) => {
  if (scenario.requiresLogin) {
    await page.goto('https://staging.ppetoolkit.com/wp-login.php');
    await page.waitForSelector('#user_login');
    await page.type('#user_login', 'test-student');
    await page.type('#user_pass', 'test-password');
    await page.click('#wp-submit');
    await page.waitForNavigation();
  }
};
```

Then reference it in your scenario:

```json
{
  "onBeforeScript": "login-ppetoolkit.js",
  "requiresLogin": true
}
```

> **Security:** Never commit real credentials. Use a dedicated test account with limited permissions. Store credentials in environment variables or a local `.env` file that is gitignored.

---

## Workflow: Running Visual Regression Tests

### During an Update Cycle

Follow these steps as part of the [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md), Step 5.

#### 1. Capture Reference (Production)

Before syncing production to staging (or right before updating staging):

```bash
# Capture reference screenshots from production
backstop reference
```

This captures the current state of production pages as your baseline.

#### 2. Update Staging

Follow the SOP to sync production to staging and apply updates.

#### 3. Capture Test (Staging)

After updates are applied on staging:

```bash
# Capture test screenshots from staging
backstop test
```

This captures the staging pages and compares them against the reference.

#### 4. Review the Report

```bash
# Open the HTML report in your browser
backstop openReport
```

The report shows:
- **Green:** Pages that match (no visual changes)
- **Red/Pink:** Pages with visual differences (highlighted in magenta)
- **Side-by-side comparison:** Reference (production) vs. Test (staging)
- **Diff overlay:** Highlighting exactly where changes occurred

#### 5. Evaluate Results

- **Expected changes:** Updated copyright year, new content, etc. -- these are fine
- **Unexpected changes:** Broken layouts, missing images, shifted elements -- investigate before proceeding
- **Dynamic content:** Calendar dates, timestamps, etc. will show as diffs -- these are usually acceptable

---

## Tips and Best Practices

### Exclude Dynamic Elements

Dynamic elements (dates, counters, rotating banners) will always show as visual differences. Exclude them using `removeSelectors` or `hideSelectors`:

```json
{
  "removeSelectors": [
    ".dynamic-date",
    ".rotating-banner",
    ".cookie-notice",
    ".popup-overlay",
    ".chat-widget"
  ],
  "hideSelectors": [
    ".live-counter",
    ".timestamp"
  ]
}
```

- `removeSelectors`: Completely removes the element from the DOM before screenshot
- `hideSelectors`: Sets the element to `visibility: hidden` (preserves layout space)

### Adjust Mismatch Threshold

- `0.1` (default): Very strict -- catches tiny changes
- `0.5`: Moderate -- good for most pages
- `1.0`: Lenient -- good for dynamic pages (calendars, carts)
- `5.0`: Very lenient -- only catches major layout breaks

Use higher thresholds for pages with dynamic content (event calendars, shopping carts).

### Run Reference Right Before Update Cycle

Always capture a fresh reference immediately before the update cycle. Stale references will produce false positives from content changes unrelated to updates.

### Wait for Page Load

Use the `delay` property (in milliseconds) to wait for JavaScript-rendered content:
- Simple pages: `delay: 2000` (2 seconds)
- Heavy pages (Elementor, LearnDash): `delay: 5000` (5 seconds)
- Pages with animations: use `postInteractionWait: 1000` after scrolling

---

## .gitignore Addition

Add the BackstopJS data directory to your `.gitignore` to avoid committing screenshot data:

```
# BackstopJS
backstop_data/
```

---

## Alternative Tools

If BackstopJS does not meet your needs, consider these alternatives:

| Tool | Type | Cost | Best For |
|------|------|------|----------|
| **BackstopJS** | CLI, local | Free | Full control, custom scenarios, CI/CD integration |
| **Playwright** | Testing framework | Free | Developers who want full E2E + visual testing |
| **Percy** | Cloud service | $250+/month | Team collaboration, AI-powered diffing |
| **Diffy** | Cloud service | ~$99/month | WordPress-native, automatic pre/post screenshots |

### Note on Kinsta Automatic Updates

Kinsta offers a paid add-on ($3/env/month) called "Kinsta Automatic Updates" that includes automatic plugin/theme updates with built-in visual regression testing and rollback. While this exists as a Kinsta feature, **it is not used for PPE Medical sites** for the following reasons:

- It is a paid add-on, not included in standard hosting
- It runs updates automatically without human review of changelogs or release notes
- It cannot handle the staged workflow needed for custom code (e.g., QBank on ppetoolkit.com)
- It only tests up to 5 URLs and cannot verify functional behavior (checkout flows, quiz submissions, form processing)
- Custom/premium plugins may not update correctly through this service

Our human-handled staged update process (see [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)) provides full control over update order, per-plugin testing, functional regression testing, and proper escalation -- which is essential for business-critical sites with custom code and payment processing.

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md) (Step 5 references this guide)
- [Regression Test Checklist: ppemedical.com](../checklists/regression-test-ppemedical-com.md)
- [Regression Test Checklist: ppetoolkit.com](../checklists/regression-test-ppetoolkit-com.md)
- [Regression Test Checklist: ppemedevents.com](../checklists/regression-test-ppemedevents-com.md)

---

*Last updated: 2026-02-11*
