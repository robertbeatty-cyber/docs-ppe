# Regression Test Checklist: ppemedical.com

**Last updated:** 2026-02-11
**Site:** https://ppemedical.com
**Staging:** https://staging.ppemedical.com
**Risk level:** High
**Total plugins:** 42 active
**Key risk areas:** WooCommerce + Authorize.Net payment processing

---

## 1. General Site Functionality

- [ ] Homepage loads correctly
- [ ] Main navigation menu works (all top-level and dropdown items)
- [ ] Footer links work correctly
- [ ] Site search returns results
- [ ] Mobile responsive layout displays correctly (test on phone or browser dev tools)
- [ ] No JavaScript console errors on key pages (homepage, shop, product page, cart, checkout)
- [ ] SSL certificate is valid (padlock icon in browser)
- [ ] Site loads within acceptable time (no obvious performance regression)

---

## 2. WooCommerce Core

- [ ] Shop page displays products correctly
- [ ] Product category pages load and filter correctly
- [ ] Individual product pages display correctly (images, pricing, descriptions, add-to-cart button)
- [ ] Variable products show variation options correctly
- [ ] "Add to Cart" button works
- [ ] Cart page displays correct items, quantities, and pricing
- [ ] Cart updates work (change quantity, remove item)
- [ ] Proceed to checkout from cart works

---

## 3. Checkout & Payment Processing (Authorize.Net)

> **Important:** Test a complete checkout flow. If on staging, use test credentials or verify gateway status page.

- [ ] Checkout page loads with all required fields
- [ ] Checkout form validates required fields (name, address, email, payment)
- [ ] Credit card fields display correctly (Authorize.Net gateway)
- [ ] Place order button is functional
- [ ] Order confirmation page displays after successful order
- [ ] Order confirmation email is sent
- [ ] Order appears in WooCommerce > Orders in admin
- [ ] WooCommerce Authorize.Net Gateway settings page loads without errors
- [ ] WooCommerce Authorize.net Gateway (Enterprise) settings page loads without errors

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

- [ ] Contact form(s) submit successfully
- [ ] Form submission confirmation displays
- [ ] Form notification emails are received (check via WP Mail SMTP Pro > Email Log if available)
- [ ] WP Mail SMTP Pro settings page loads, connection status shows "Connected"

---

## 9. Security Plugins

- [ ] NinjaFirewall: Firewall status shows "Enabled" in admin
- [ ] NinjaScanner: Scanner settings page loads without errors
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

- [ ] Redirection plugin: Settings page loads in admin
- [ ] Test 1-2 known redirects to confirm they still work
- [ ] Check redirect logs for any new 404 errors

---

## 14. Other Plugins

- [ ] GenerateBlocks: Blocks render correctly on pages that use them
- [ ] GP Premium: Theme customizations remain intact
- [ ] Reusable Content & Text Blocks: Shortcodes render content correctly
- [ ] Stream: Activity log shows recent events in admin
- [ ] Temporary Login: Settings page loads
- [ ] WPFront User Role Editor: Settings page loads
- [ ] Git Updater: Settings page loads
- [ ] IgniteWoo Updater: Plugin active without errors
- [ ] WooCommerce.com Update Manager: No update errors in admin

---

## Plugin Version Table

| # | Plugin | Current Version | Update Available |
|---|--------|----------------|-----------------|
| 1 | Cart Abandonment Recovery for WooCommerce | 2.0.7 | - |
| 2 | Checkout Field Editor for WooCommerce (Pro) | 3.7.5 | - |
| 3 | Cloudflare | 4.14.2 | - |
| 4 | Elementor | 3.34.4 | 3.35.4 |
| 5 | Elementor Pro | 3.34.4 | 3.35.1 |
| 6 | Frontend Reset Password | 1.3.1 | 1.3.3 |
| 7 | GenerateBlocks | 2.2.0 | - |
| 8 | Git Updater | 12.22.0 | - |
| 9 | Gorilla Core Web Vitals Monitor | 1.3.8 | - |
| 10 | GP Premium | 2.5.5 | - |
| 11 | GTM4WP | 1.22.3 | - |
| 12 | IgniteWoo Updater | 3.1 | - |
| 13 | Imagify | 2.2.7 | - |
| 14 | Index WP MySQL For Speed | 1.5.6 | - |
| 15 | Microsoft Clarity | 0.10.15 | 0.10.16 |
| 16 | NinjaFirewall (WP Edition) | 4.8.3 | - |
| 17 | NinjaScanner | 3.2.8 | - |
| 18 | OttoKit | 1.1.18 | 1.1.20 |
| 19 | Perfmatters | 2.5.7 | - |
| 20 | Reusable Content & Text Blocks by Loomisoft | 1.4.3 | - |
| 21 | SaferCheckout Lite | 1.0.8 | - |
| 22 | Simple CAPTCHA Alternative with Cloudflare Turnstile | 1.37.0 | - |
| 23 | Stream | 4.1.1 | - |
| 24 | Sucuri Security | 2.6 | - |
| 25 | Temporary Login | 1.3.0 | - |
| 26 | WC Variations Radio Buttons | 2.1.1 | - |
| 27 | WooCommerce | 10.4.3 | 10.5.1 |
| 28 | WooCommerce Authorize.Net Gateway | 3.10.14 | - |
| 29 | WooCommerce Authorize.net Gateway (Enterprise) | 6.2.15 | - |
| 30 | WooCommerce Checkout Field Editor | 1.7.25 | - |
| 31 | WooCommerce Customer/Order/Coupon Export | 5.5.6 | - |
| 32 | WooCommerce Min/Max Quantities | 5.2.8 | - |
| 33 | WooCommerce Product Add-Ons | 8.1.2 | - |
| 34 | WooCommerce Product Dependencies | 2.0.1 | - |
| 35 | WooCommerce Subscriptions | 8.3.1 | 8.4.0 |
| 36 | WooCommerce Subscriptions - Custom Price String | 1.0.6 | - |
| 37 | WooCommerce.com Update Manager | 1.0.3 | - |
| 38 | WP 2FA | 3.1.0 | - |
| 39 | WP Mail SMTP Pro | 4.7.1 | - |
| 40 | WPFront User Role Editor | 4.2.4 | - |
| 41 | Yoast SEO | 26.8 | 26.9 |
| 42 | Yoast SEO Premium | 26.8 | 26.9 |

**Updates currently available (9):** Elementor 3.35.4, Elementor Pro 3.35.1, Frontend Reset Password 1.3.3, Microsoft Clarity 0.10.16, OttoKit 1.1.20, WooCommerce 10.5.1, WooCommerce Subscriptions 8.4.0, Yoast SEO 26.9, Yoast SEO Premium 26.9

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)

---

*Last updated: 2026-02-11*
