# Checklists - Regression Test Checklists

Per-site regression test checklists for PPE Medical's three WordPress websites. Execute these checklists during the [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md) (Steps 4 and 8).

---

## Regression Test Checklists

| Checklist | Plugins | Risk Level | Key Concern |
|-----------|---------|------------|-------------|
| [ppemedical.com](regression-test-ppemedical-com.md) | 42 | High | WooCommerce + Authorize.Net payment processing |
| [ppetoolkit.com](regression-test-ppetoolkit-com.md) | 42 | **Critical** | LearnDash + custom QBank code |
| [ppemedevents.com](regression-test-ppemedevents-com.md) | 11 | Standard | Events Calendar + Event Tickets |

---

## Usage

1. Open the checklist for the site you are testing
2. Test against the **staging** site first (SOP Step 4)
3. Test against the **production** site after updates (SOP Step 8)
4. Document pass/fail for each item
5. If critical items fail, STOP and escalate per the SOP

---

See the [main README](../README.md) for repository overview.
