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

### ppemedical.com - Payment Processing
- Runs WooCommerce with dual Authorize.Net payment gateways
- Payment processing must be verified after every update cycle
- WooCommerce Subscriptions handles recurring billing

### ppemedevents.com - Simplest Site
- Only 11 plugins (vs 42 on the other two sites)
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
