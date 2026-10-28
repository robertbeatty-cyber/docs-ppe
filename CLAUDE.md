# CLAUDE.md - PPE Medical Documentation Repository

## Repository Overview

This repository contains operational documentation for PPE Medical's three business-critical WordPress websites hosted on Kinsta. It includes SOPs for staged website updates, per-site regression test checklists, and testing guides.

**This is a documentation-only repository.** No application code lives here.

## The Three Websites

| Site | URL | Purpose | Risk Level |
|------|-----|---------|------------|
| ppemedical.com | https://ppemedical.com | Medical products (WooCommerce) | High |
| ppetoolkit.com | https://ppetoolkit.com | Education/Quiz platform (LearnDash) | Critical |
| ppemedevents.com | https://ppemedevents.com | Medical events (Events Calendar) | Standard |

## Critical Context

### ppetoolkit.com - Custom QBank Code (HIGHEST RISK)
- The site uses a **custom QBank plugin** ("LD - Quiz Customization Question Bank" v2.1.0 by WisdmLabs) that integrates deeply with LearnDash
- There is also a **custom quiz button plugin** ("Wisdmlabs Quiz button Customization" v1.0.0)
- LearnDash major version updates (e.g., 4.x to 5.x) can break this custom code
- LearnDash 5.0 changed REST API field names (`inProgress` to `in_progress`)
- **The client specifically requested** staging testing before any LearnDash updates
- Always update LearnDash ALONE first on staging, test QBank thoroughly, then proceed with other plugins
- LearnDash is on **5.2.2.1** (updated 2026-10-29) and is **no longer pinned**. It was held at 5.1.4 from July to October (#218633)
- **Why content went blank in July (proven 2026-10-29):** from LearnDash 5.1.5, users whose role lacks the `read` capability see blank lessons/topics. On 2026-10-29 `read` was added to `staff`, `author`, `editor`, `contributor` and `customer`. Any role that should see course content must keep `read`. See `reference/ppetoolkit-learndash-read-capability.md`

### Plugin Version Pinning - Gorilla Essentials
- The **Gorilla Essentials** plugin (Gorilla DevOps, repo `gorilla-essentials`) is active on all three sites
- It can pin any plugin, or WordPress core, at a known-good version: Tools > Gorilla Essentials > Plugin Locks
- A pinned plugin's newer updates are hidden, auto-updates are refused, and manual/WP-CLI updates are blocked
- See "Pinning a Plugin Version" in the staged website updates SOP

### ppemedical.com - Payment Processing
- Runs WooCommerce with Stripe as the card gateway at checkout, plus PayPal Payments (#960885)
- Authorize.Net (Enterprise, gateway id `authnet`) must stay **enabled**: most active subscriptions still renew through it. It is hidden from checkout only, by the child theme flag `hide_authnet_gateway` in `gp-ppemedical/functions.php`
- Keep **both** Authorize.Net plugins active (Enterprise and CIM) for renewals of older customers on those gateways (operator decision 2026-10-28). Neither appears on checkout: Enterprise is hidden by the theme flag, and the CIM payment methods are disabled
- Payment processing must be verified after every update cycle
- WooCommerce Subscriptions handles recurring billing

### ppemedevents.com - Simplest Site
- Only 13 plugins (vs 44-48 installed on the other two sites, as of 2026-10-29)
- The whole site is **deliberately behind a site-wide password** (Password Protected plugin). Unauthenticated REST calls return 401 by design; only Promoter's IP and specific routes are allowlisted (see the ansible-v2 ppemedevents runbook)
- Password Protected's **"Allow REST API" setting must stay OFF**. Before 2.8.5 a plugin bug blocked REST even with it on; 2.8.5 fixed that, so with it on the REST API is public (found 2026-10-28)
- Standard Events Calendar implementation
- Good candidate for updating first in any cycle

## Repository Structure

```
├── CONVENTIONS.md         (documentation standards)
├── CLAUDE.md              (this file)
├── README.md              (entry point)
├── sops/maintenance/      (staged update SOP)
├── checklists/            (per-site regression test checklists)
├── guides/                (testing guides)
└── scripts/               (WP-CLI update & regression test scripts)
```

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for full details.

Key rules:
- File naming: lowercase-with-hyphens, preserve uppercase acronyms (SOP)
- Commit messages: `[Type]: description` where Type is Docs/SOP/Checklist/Guide/Fix/Refactor
- **No em dashes** anywhere in documentation (use regular dashes or --)
- SOP metadata header: Version, Date, Status, Last updated, Applies to, Purpose
- All documents must have a "Last updated" date

## Git Rules

- **Never add "Co-Authored-By" lines** or any AI/Claude attribution to commit messages
- **Never add "Generated with Claude"** or similar AI references to commits, PRs, or documentation
- **Shorthand "cp" means commit and push** -- when the user says "cp", create the commit and push it to the remote in one step

## Roles

- **Maintenance Technician** - Performs monthly update cycles for all three sites
- **Technical Lead** - Escalation point for critical issues
- **Site Owner** - Client contact at PPE Medical

## Update Schedule

- **Frequency:** Monthly
- **Estimated time:** 1.5-2 hours per cycle (all three sites)
- **Recommended order:** ppemedevents.com (simplest) -> ppemedical.com -> ppetoolkit.com (highest risk)
