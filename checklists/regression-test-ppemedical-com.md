# Regression Test Checklist: ppemedical.com

**Last updated:** 2026-10-29
**Last executed:** 2026-10-28 (staging, then production: plugins, WordPress core 7.1.3, child theme 3.15.111); WordPress 7.1.4 security release applied 2026-10-29
**Site:** https://ppemedical.com
**Staging:** https://staging.ppemedical.com
**Risk level:** High
**Total plugins:** 46 active, 2 inactive, plus 6 must-use (as of 2026-10-28)
**Key risk areas:** WooCommerce checkout (Stripe + PayPal) and Authorize.Net subscription renewals

---

## 0. Staging Setup (staging only, before testing)

- [ ] Outbound email blocked: Tools > Gorilla Essentials > Site Hygiene shows **"Always block outside production, including a hostname guess"** (see SOP Step 2)
- [ ] Stripe connected in **test mode** so checkout shows a card option (see SOP Step 4)
- [ ] Your country unticked in WooCommerce > Settings > SaferCheckout Lite, **staging only**, if you are testing from outside the US

---

## 1. General Site Functionality

- [ ] Homepage loads correctly
- [ ] Main navigation menu works (all top-level and dropdown items)
- [ ] Footer links work correctly
- [ ] Site search: N/A, the site has no search box (checked 2026-10-28)
- [ ] Mobile responsive layout displays correctly (test on phone or browser dev tools)
- [ ] No JavaScript console errors on key pages (homepage, shop, product page, cart, checkout)
- [ ] SSL certificate is valid (padlock icon in browser)
- [ ] Site loads within acceptable time (no obvious performance regression)

---

## 2. WooCommerce Core

- [ ] Product listing pages display products correctly. Customers browse through **Online Packages** and the workshop pages. `/shop/` exists and lists products but nothing in the navigation links to it
- [ ] Product category pages load and filter correctly
- [ ] Individual product pages display correctly (images, pricing, descriptions, add-to-cart button)
- [ ] Variable products show variation options correctly
- [ ] "Add to Cart" button works
- [ ] **Express checkout buttons render on product pages** (Stripe: Apple Pay / Google Pay / Link, plus PayPal). Test in an incognito window; the console check `tests/console/ppemedical-console-checks.js` flags whether they rendered.
- [ ] **Each express checkout button, when clicked, opens the correct checkout flow** (Stripe / PayPal). Wallet buttons only appear on a device with that wallet, so confirm on a real device.
- [ ] Cart page displays correct items, quantities, and pricing
- [ ] Cart updates work (change quantity, remove item)
- [ ] Proceed to checkout from cart works

---

## 3. Checkout & Payment Processing (Stripe, PayPal, Authorize.Net renewals)

> **Important:** Test a complete checkout flow. If on staging, use test credentials or verify gateway status page.

> **Gateway setup (Ticket #960885):** Stripe replaced Authorize.Net as the card gateway at checkout. The Authorize.Net gateway (`authnet`, from the "WooCommerce Authorize.net Gateway (Enterprise)" plugin) must stay **enabled**, because existing subscriptions renew through it (283 of 393 active subscriptions on 2026-10-28). It is hidden from checkout only, by the child theme flag `hide_authnet_gateway => true` in `gp-ppemedical/functions.php`. Do not disable the gateway or deactivate the plugin to "clean up".

- [ ] Checkout page loads with all required fields
- [ ] Checkout form validates required fields (name, address, email, payment)
- [ ] **Checkout shows Stripe (Credit / Debit Card) and PayPal only**
- [ ] **Authorize.Net does NOT appear as a payment option on checkout** (no `payment_method_authnet` radio). If it shows, the child theme flag was lost in a theme update.
- [ ] Stripe card fields display and accept input
- [ ] Place order button is functional
- [ ] Order confirmation page displays after successful order
- [ ] Order confirmation email is sent
- [ ] Order appears in WooCommerce > Orders in admin
- [ ] WooCommerce > Settings > Payments: Stripe, PayPal and Authorize.net (`authnet`, title "Credit card") are all **enabled**
- [ ] Plugins: **both** Authorize.Net plugins stay **active** ("WooCommerce Authorize.net Gateway (Enterprise)" and "WooCommerce Authorize.Net Gateway" (CIM)) for renewals of older customers. Do not deactivate either
- [ ] WooCommerce > Settings > Payments: the CIM credit card and eCheck methods remain **disabled**, so they do not appear on checkout
- [ ] WooCommerce Authorize.net Gateway (Enterprise) settings page loads without errors
- [ ] WooCommerce Stripe Gateway settings page loads, account shows as connected
- [ ] Tools > Scheduled Actions: no new failed `woocommerce_scheduled_subscription_payment` actions since the update

---

## 4. WooCommerce Subscriptions

- [ ] Subscription products display correctly on shop and product pages
- [ ] Subscription pricing and billing period shown correctly
- [ ] Subscription sign-up flow works through checkout
- [ ] My Account > Subscriptions page loads for logged-in users
- [ ] Existing subscription details display correctly
- [ ] Custom Price String plugin: subscription price text renders correctly

---

## 5. WooCommerce Extensions

- [ ] **Min/Max Quantities:** Product quantity restrictions enforced on cart/checkout
- [ ] **Product Add-Ons:** Extra product options display on product pages, pricing adjusts correctly
- [ ] **Product Dependencies:** Restricted products show appropriate messaging
- [ ] **Cart Abandonment Recovery:** Plugin settings page loads without errors
- [ ] **Checkout Field Editor (Pro):** Custom checkout fields display correctly
- [ ] **WC Variations Radio Buttons:** Product variations show as radio buttons instead of dropdowns
- [ ] **Customer/Order/Coupon Export:** Export settings page accessible in admin

---

## 6. Elementor & Elementor Pro

- [ ] Pages built with Elementor render correctly on the frontend
- [ ] No broken layouts or missing sections
- [ ] Elementor editor loads in admin (edit any page with Elementor)
- [ ] Dynamic content and widgets display correctly
- [ ] Forms created with Elementor Pro submit successfully (if any)

---

## 7. Yoast SEO & Yoast SEO Premium

- [ ] Yoast SEO meta data displays in page source (title tags, meta descriptions)
- [ ] XML sitemaps accessible at /sitemap_index.xml
- [ ] Yoast SEO admin panel loads without errors
- [ ] Social sharing previews generate correctly (check any post/page in Yoast editor panel)

---

## 8. Forms & Email

- [ ] Homepage **"Email Opt-In - Bottom of Home Page"** (Elementor Pro form) renders and submits. Submit it on staging, not production. This is the only front-end form found on 2026-10-28; the Contact Us page has no form
- [ ] Form submission confirmation displays
- [ ] Form notification emails are received (check via WP Mail SMTP Pro > Email Log if available)
- [ ] WP Mail SMTP Pro settings page loads, connection status shows "Connected"

---

## 9. Security Plugins

- [ ] Sucuri Security: Dashboard loads, no new security alerts
- [ ] WP 2FA: Two-factor authentication login flow works
- [ ] SaferCheckout Lite: Settings page loads, WooCommerce checkout protection active
- [ ] Cloudflare Turnstile: CAPTCHA displays on relevant forms

---

## 10. Performance & Optimization

- [ ] Perfmatters: Settings page loads, optimizations are active
- [ ] Imagify: Settings page loads, optimization status displays
- [ ] Cloudflare: Plugin settings page loads, connection status OK
- [ ] Index WP MySQL For Speed: Settings page loads without errors
- [ ] Gorilla Core Web Vitals Monitor: Dashboard shows data, no errors

---

## 11. User Authentication

- [ ] User login page loads (wp-login.php or custom login page)
- [ ] Login with valid credentials works
- [ ] Logout works
- [ ] Password reset flow sends email
- [ ] Frontend Reset Password: Frontend reset page loads and works
- [ ] WP 2FA: 2FA prompt displays after login for configured users

---

## 12. Analytics & Tracking

- [ ] Microsoft Clarity: Verify tracking script loads (check page source or browser dev tools for clarity.js)
- [ ] GTM4WP: Google Tag Manager container loads (check page source for gtm.js)

---

## 13. Redirections

Redirects are managed in **Yoast SEO Premium > Redirects** (about 930 entries). The Redirection plugin is no longer installed.

- [ ] Yoast SEO Premium > Redirects page loads in admin
- [ ] Test 1-2 known redirects to confirm they still work (e.g. `/appcsw1-orlando-january-18-19-2019/` returns 301 to `/appcsw1-orlando-january-17-18-2020/`)

---

## 14. Other Plugins

- [ ] GenerateBlocks / GenerateBlocks Pro: Blocks render correctly on pages that use them
- [ ] GP Premium: Theme customizations remain intact
- [ ] PPE Content Blocks: Content blocks render correctly on pages that use them
- [ ] Child theme (gp-ppemedical): version matches the release deployed by Git Updater, and its WooCommerce snippets still apply (see Section 3 checkout gateway check)
- [ ] Gorilla Essentials: Tools > Gorilla Essentials loads, Plugin Locks list is as expected
- [ ] OttoKit: Workflows connected, no failed runs since the update
- [ ] Safe SVG: SVG images still display
- [ ] Yoast SEO: WooCommerce: product schema/meta present on a product page
- [ ] Stream: Activity log shows recent events in admin
- [ ] Temporary Login: Settings page loads
- [ ] WPFront User Role Editor: Settings page loads
- [ ] Git Updater: Settings page loads
- [ ] IgniteWoo Updater: Plugin active without errors
- [ ] WooCommerce.com Update Manager: No update errors in admin

---

## Plugin Version Table

**Captured from production 2026-10-28, after the October round**, via `wp plugin list --status=active --fields=name,version --format=csv`. Slugs are included because the display name is not what WP-CLI reports, and guessing names has caused errors here before.

**Pending at capture: 0 plugin updates, 0 theme updates.** WordPress core 7.1.3 at capture (7.1.4 from 2026-10-29), child theme `gp-ppemedical` 3.15.111, `wp core verify-checksums` passes, no `wp-content/debug.log` present.

| # | Plugin | Slug | Version |
|---|--------|------|---------|
| 1 | Cart Abandonment Recovery for WooCommerce | `woo-cart-abandonment-recovery` | 2.2.2 |
| 2 | Checkout Field Editor for WooCommerce (Pro) | `woocommerce-checkout-field-editor-pro` | 3.8.0 |
| 3 | Cloudflare | `cloudflare` | 4.14.5 |
| 4 | Elementor | `elementor` | 4.3.5 |
| 5 | Elementor Pro | `elementor-pro` | 4.3.2 |
| 6 | Frontend Reset Password | `frontend-reset-password` | 1.3.3 |
| 7 | GenerateBlocks | `generateblocks` | 2.5.0 |
| 8 | GenerateBlocks Pro | `generateblocks-pro` | 2.8.0 |
| 9 | Git Updater | `git-updater` | 14.4.3 |
| 10 | Gorilla Core Web Vitals Monitor | `gorilla-cwv-monitor` | 1.8.0 |
| 11 | Gorilla Essentials | `gorilla-essentials` | 0.3.17 |
| 12 | GP Premium | `gp-premium` | 2.5.6 |
| 13 | GTM4WP (Google Tag Manager for WordPress) | `duracelltomi-google-tag-manager` | 2.0.6 |
| 14 | IgniteWoo Updater | `ignitewoo-updater` | 3.1 |
| 15 | Imagify | `imagify` | 2.3.4 |
| 16 | Index WP MySQL For Speed | `index-wp-mysql-for-speed` | 1.6.0 |
| 17 | Microsoft Clarity | `microsoft-clarity` | 0.10.37 |
| 18 | OttoKit (SureTriggers) | `suretriggers` | 1.1.42 |
| 19 | Perfmatters | `perfmatters` | 2.6.9 |
| 20 | PPE Content Blocks | `ppe-content-blocks` | 1.1.2 |
| 21 | Safe SVG | `safe-svg` | 2.5.2 |
| 22 | SaferCheckout Lite | `safercheckout-lite` | 1.13 |
| 23 | Simple Cloudflare Turnstile | `simple-cloudflare-turnstile` | 1.44.0 |
| 24 | Stream | `stream` | 4.4.0 |
| 25 | Sucuri Security | `sucuri-scanner` | 2.8.1 |
| 26 | Temporary Login | `temporary-login` | 1.3.0 |
| 27 | WC Variations Radio Buttons | `wc-variations-radio-buttons` | 2.1.1 |
| 28 | WooCommerce | `woocommerce` | 11.2.1 |
| 29 | WooCommerce Authorize.Net Gateway (CIM) | `woocommerce-gateway-authorize-net-cim` | 3.10.21 |
| 30 | WooCommerce Authorize.net Gateway (Enterprise) | `woo-authorize-net-gateway-enterprise` | 6.2.20 |
| 31 | WooCommerce Checkout Field Editor | `woocommerce-checkout-field-editor` | 1.7.28 |
| 32 | WooCommerce Customer/Order/Coupon Export | `woocommerce-customer-order-csv-export` | 5.7.0 |
| 33 | WooCommerce Min/Max Quantities | `woocommerce-min-max-quantities` | 5.2.15 |
| 34 | WooCommerce PayPal Payments | `woocommerce-paypal-payments` | 4.2.0 |
| 35 | WooCommerce Product Add-Ons | `woocommerce-product-addons` | 8.4.5 |
| 36 | WooCommerce Product Dependencies | `woocommerce-product-dependencies` | 2.0.1 |
| 37 | WooCommerce Stripe Gateway | `woocommerce-gateway-stripe` | 11.1.1 |
| 38 | WooCommerce Subscriptions | `woocommerce-subscriptions` | 9.3.0 |
| 39 | WooCommerce Subscriptions - Custom Price String | `woocommerce-subscriptions-custom-price-string-master` | 1.0.6 |
| 40 | WooCommerce.com Update Manager | `woo-update-manager` | 1.0.3 |
| 41 | WP 2FA | `wp-2fa` | 4.2.1 |
| 42 | WP Mail SMTP Pro | `wp-mail-smtp-pro` | 4.10.3 |
| 43 | WPFront User Role Editor | `wpfront-user-role-editor` | 4.2.5 |
| 44 | Yoast SEO | `wordpress-seo` | 28.8 |
| 45 | Yoast SEO Premium | `wordpress-seo-premium` | 28.8 |
| 46 | Yoast SEO: WooCommerce | `wpseo-woocommerce` | 16.8 |

### Inactive (installed, not active)

| Plugin | Slug | Version |
|--------|------|---------|
| Reusable Content & Text Blocks by Loomisoft | `loomisoft-content-blocks` | 1.4.3 |
| Simple History | `simple-history` | 5.36.0 |

### Must-use

| Plugin | Slug | Version |
|--------|------|---------|
| Activity Log | `activity-log-plugin` | 1.0.0 |
| Code Profiler | `0----code-profiler` | 1.0 |
| Index WP MySQL For Speed update filter | `index-wp-mysql-for-speed-update-filter` | 1.6.0 |
| Kinsta MU Plugins | `kinsta-mu-plugins` | 3.6.1 |
| Perfmatters MU | `perfmatters_mu` | 2.6.9 |
| Simple History MU | `simple_history_mu` | 5.34.0 |

> **NinjaFirewall and NinjaScanner are no longer installed on this site** - not active, not inactive, not must-use (verified 2026-10-28). Section 9 no longer tests them; Sucuri Security is the remaining security scanner.

> **Two Authorize.Net plugins are installed and that is intentional.** `woo-authorize-net-gateway-enterprise` (IgniteWoo) provides the `authnet` gateway that carries subscription renewals and stays enabled but hidden from checkout. `woocommerce-gateway-authorize-net-cim` provides `authorize_net_cim_credit_card`, which is disabled. Do not remove either to tidy up.
---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)

---

*Last updated: 2026-10-29*
