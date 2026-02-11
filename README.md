# PPE Medical - Documentation Repository

Operational documentation for PPE Medical's three WordPress websites hosted on Kinsta. This repository contains SOPs, regression test checklists, and testing guides for the staged website update process.

**Originating ticket:** #858937 (RFC: Staged updates process)

---

## Site Overview

| Site | Production URL | Staging URL | Purpose | Risk Level |
|------|---------------|-------------|---------|------------|
| ppemedical.com | https://ppemedical.com | https://staging.ppemedical.com | Medical products store (WooCommerce) | High |
| ppetoolkit.com | https://ppetoolkit.com | https://staging.ppetoolkit.com | Education/Quiz platform (LearnDash + custom QBank) | **Critical** |
| ppemedevents.com | https://ppemedevents.com | https://staging.ppemedevents.com | Medical events (Events Calendar) | Standard |

> **Warning:** ppetoolkit.com uses custom QBank code that integrates with LearnDash. LearnDash major version updates require special handling -- always test on staging first and update LearnDash separately from other plugins.

---

## Documents

### SOPs

| Document | Description |
|----------|-------------|
| [Staged Website Updates SOP](sops/maintenance/staged-website-updates-SOP.md) | Complete 9-step workflow for monthly update cycles |
| [Visual Regression Testing SOP](sops/maintenance/visual-regression-testing-SOP.md) | Install, configure, and run BackstopJS |

### Regression Test Checklists

| Checklist | Plugins | Risk Level |
|-----------|---------|------------|
| [ppemedical.com](checklists/regression-test-ppemedical-com.md) | 42 plugins (WooCommerce + Authorize.Net) | High |
| [ppetoolkit.com](checklists/regression-test-ppetoolkit-com.md) | 42 plugins (LearnDash + custom QBank) | **Critical** |
| [ppemedevents.com](checklists/regression-test-ppemedevents-com.md) | 11 plugins (Events Calendar) | Standard |

### Guides

| Guide | Description |
|-------|-------------|
| [Visual Regression Testing Guide](guides/visual-regression-testing-guide.md) | BackstopJS setup, configuration, and workflow |

### Scripts

| Script | Site | Description |
|--------|------|-------------|
| [update-ppemedevents.sh](scripts/update-ppemedevents.sh) | ppemedevents.com | WP-CLI update + regression checks (standard risk, bulk update) |
| [update-ppemedical.sh](scripts/update-ppemedical.sh) | ppemedical.com | WP-CLI update + regression checks (high risk, WooCommerce order) |
| [update-ppetoolkit.sh](scripts/update-ppetoolkit.sh) | ppetoolkit.com | WP-CLI update + regression checks (critical risk, LearnDash-first with QBank pause) |

See [scripts/README.md](scripts/README.md) for usage instructions.

---

## Key Information

| Item | Detail |
|------|--------|
| **Assigned to** | Maintenance Technician |
| **Update schedule** | Monthly |
| **Estimated time** | 1.5-2 hours per cycle (all three sites) |
| **Hosting** | Kinsta (MyKinsta dashboard) |
| **Recommended update order** | ppemedevents.com -> ppemedical.com -> ppetoolkit.com |
| **Escalation contact** | Technical Lead |
| **Client contact** | Site Owner |

---

## Special Considerations

1. **ppetoolkit.com LearnDash updates:** Always update LearnDash ALONE first on staging, test QBank functionality thoroughly, then proceed with other plugins. LearnDash 5.0+ changed API field names (`inProgress` to `in_progress`) which can break custom quiz code.

2. **ppemedical.com payment processing:** WooCommerce and Authorize.Net gateway updates require payment flow verification. Never push to production without confirming checkout works on staging.

3. **Update order matters:** Start with ppemedevents.com (simplest, 11 plugins) to build confidence, then ppemedical.com, then ppetoolkit.com (highest risk) last.

---

## Repository Structure

```
docs-ppe/
├── CLAUDE.md
├── CONVENTIONS.md
├── README.md
├── sops/
│   ├── README.md
│   └── maintenance/
│       ├── staged-website-updates-SOP.md
│       └── visual-regression-testing-SOP.md
├── checklists/
│   ├── README.md
│   ├── regression-test-ppemedical-com.md
│   ├── regression-test-ppetoolkit-com.md
│   └── regression-test-ppemedevents-com.md
├── guides/
│   ├── README.md
│   └── visual-regression-testing-guide.md
└── scripts/
    ├── README.md
    ├── update-ppemedevents.sh
    ├── update-ppemedical.sh
    └── update-ppetoolkit.sh
```

---

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for file naming, commit message format, and document structure standards.

---

*Last updated: 2026-02-11*
