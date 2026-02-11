# Regression Test Checklist: ppetoolkit.com

**Last updated:** 2026-02-11
**Site:** https://ppetoolkit.com
**Staging:** https://staging.ppetoolkit.com
**Risk level:** Critical
**Total plugins:** 42 (39 active, 3 inactive)
**Key risk areas:** LearnDash LMS + custom QBank code

---

> **CRITICAL WARNING:** This site uses custom QBank code ("LD - Quiz Customization Question Bank" v2.1.0 by WisdmLabs) that deeply integrates with LearnDash. LearnDash major version updates can break quiz functionality. Always update LearnDash ALONE first, test QBank thoroughly, then proceed with other plugins. If QBank breaks, STOP and escalate to the Technical Lead immediately.

---

## 1. General Site Functionality

- [ ] Homepage loads correctly
- [ ] Main navigation menu works (all top-level and dropdown items)
- [ ] Footer links work correctly
- [ ] Site search returns results
- [ ] Mobile responsive layout displays correctly
- [ ] No JavaScript console errors on key pages (homepage, course listing, quiz page, login)
- [ ] SSL certificate is valid (padlock icon in browser)
- [ ] Site loads within acceptable time

---

## 2. LearnDash Core

- [ ] Course listing page displays all courses correctly
- [ ] Individual course page loads with correct content
- [ ] Course enrollment works (test with a test student account)
- [ ] Lesson pages load and display content correctly
- [ ] Topic pages load and display content correctly
- [ ] Course progress tracking updates correctly (mark a lesson complete, verify progress bar)
- [ ] Course navigation (next/previous lesson) works
- [ ] Certificate generation works (complete a course or use a test certificate)
- [ ] LearnDash admin settings page loads without errors

---

## 3. QBank Functionality - CRITICAL

> **This is the highest-risk area.** Test thoroughly after any LearnDash update.

**Admin Interface:**
- [ ] QBank admin menu is accessible in WordPress admin
- [ ] Question bank management interface loads correctly
- [ ] Question categories display correctly
- [ ] Creating/editing questions works (test if needed)

**Quiz Frontend:**
- [ ] Quiz page loads correctly for a logged-in student
- [ ] Questions are pulled from the question bank and display correctly
- [ ] Question randomization works (if enabled -- refresh quiz to see different question order)
- [ ] Answer options display correctly (radio buttons, checkboxes, text fields as applicable)
- [ ] Quiz timer displays and counts down (if timer is enabled)

**Quiz Submission & Scoring:**
- [ ] Submitting quiz answers works without errors
- [ ] Quiz scoring calculates correctly
- [ ] Quiz results page displays with correct score
- [ ] Quiz progress is saved to the student's profile
- [ ] Quiz retry functionality works (if configured)

**Wisdmlabs Quiz Button Customization:**
- [ ] Start Quiz button displays with correct custom text
- [ ] Finish Quiz button displays with correct custom text
- [ ] Buttons are functional (start actually starts quiz, finish actually submits)

---

## 4. LearnDash API Compatibility

> **Note:** LearnDash 5.0 changed REST API field names (e.g., `inProgress` to `in_progress`). If you updated from LearnDash 4.x to 5.x, verify these items carefully.

- [ ] No PHP errors in the error log related to LearnDash or QBank (check MyKinsta > Logs)
- [ ] Course progress data displays correctly (not showing null/undefined values)
- [ ] Student dashboard shows correct enrollment and progress data
- [ ] Any API-driven pages or widgets display data correctly

---

## 5. LearnDash Add-ons

- [ ] **Certificate Builder:** Certificate builder admin page loads, existing certificates render correctly
- [ ] **LearnDash - Elementor:** LearnDash Elementor widgets render on pages that use them
- [ ] **LearnDash - GravityForms Integration:** Form-based enrollment or triggers function (if configured)
- [ ] **SnapOrbital Notes:** Students can view and create notes on course/lesson pages, [learndash_my_notes] shortcode works
- [ ] **Uncanny Toolkit for LearnDash:** Module settings page loads, enabled modules function correctly
- [ ] **Uncanny Toolkit Pro for LearnDash:** Pro module settings page loads, enabled pro modules function correctly

---

## 6. Gravity Forms Ecosystem

- [ ] Gravity Forms: Settings page loads, existing forms are listed
- [ ] Test a form submission (use a test form or a non-critical contact form)
- [ ] Form confirmation/redirect works after submission
- [ ] Form notification emails are sent
- [ ] **Gravity Forms + Custom Post Types:** CPT mapping functions correctly (if configured)
- [ ] **ActiveCampaign Add-On:** Settings page shows connected status
- [ ] **Survey Add-On:** Survey forms display correctly (if any exist)
- [ ] **User Registration Add-On:** Registration forms create users correctly (if configured)
- [ ] **Gravity Forms All Fields Template:** {all_fields} merge tag renders correctly in notifications
- [ ] **Gravity PDF:** PDF generation works for forms with PDF feeds configured

---

## 7. Elementor & Elementor Pro

- [ ] Pages built with Elementor render correctly on the frontend
- [ ] No broken layouts or missing sections
- [ ] Elementor editor loads in admin (edit any page with Elementor)
- [ ] Dynamic content and widgets display correctly
- [ ] LearnDash-specific Elementor widgets render correctly

---

## 8. User Authentication & Roles

- [ ] Student login works (test with a student test account)
- [ ] Student dashboard loads correctly after login
- [ ] Student sees only their enrolled courses
- [ ] Instructor/admin login works
- [ ] Role-based content restrictions function (e.g., enrolled-only content is gated)
- [ ] Logout works
- [ ] Frontend Reset Password: Frontend reset page loads and sends email
- [ ] **LoginPress:** Custom login page displays correctly
- [ ] **LoginPress Pro:** Custom login styling and features are active

---

## 9. Security Plugins

- [ ] NinjaFirewall: Firewall status shows "Enabled" in admin
- [ ] NinjaScanner: Scanner settings page loads without errors
- [ ] Sucuri Security: Dashboard loads, no new security alerts

---

## 10. Performance & Optimization

- [ ] Imagify: Settings page loads, optimization status displays
- [ ] Index WP MySQL For Speed: Settings page loads without errors
- [ ] Speculative Loading: Settings page loads, prefetch/prerender rules active
- [ ] Embed Optimizer: Active and no errors in console
- [ ] Enhanced Responsive Images: Active and no errors
- [ ] Modern Image Formats: Settings page loads, WebP/AVIF conversion working
- [ ] PNG to JPG: Settings page loads

---

## 11. Other Plugins

- [ ] Code Snippets: Snippets page loads, active snippets are running (check a page that uses custom code)
- [ ] LightStart: Maintenance mode is NOT accidentally enabled (site should be live)
- [ ] Reusable Content & Text Blocks: Shortcodes render content correctly
- [ ] Stream: Activity log shows recent events in admin
- [ ] OttoKit: Dashboard loads, automations are running
- [ ] WP Mail SMTP: Settings page loads, connection status shows working
- [ ] WPFront User Role Editor: Settings page loads
- [ ] Git Updater: Settings page loads

---

## 12. LearnDash Update-Specific Tests

> **Run these tests ONLY when LearnDash has been updated (especially major version updates).**

- [ ] Verify QBank plugin (LD - Quiz Customization Question Bank) is still listed as active
- [ ] Verify Wisdmlabs Quiz button Customization plugin is still listed as active
- [ ] Check PHP error log for new LearnDash-related errors
- [ ] Complete a full quiz attempt from start to finish as a student
- [ ] Verify quiz score appears in student's course progress
- [ ] Verify quiz results appear in admin reporting (LearnDash > Quiz Statistics)
- [ ] Check that course completion certificates still generate
- [ ] Test course enrollment from a Gravity Forms registration (if applicable)
- [ ] Verify all Uncanny Toolkit modules still function

---

## Plugin Version Table

| # | Plugin | Current Version | Update Available | Notes |
|---|--------|----------------|-----------------|-------|
| 1 | Code Snippets | 3.9.4 | 3.9.5 | |
| 2 | Elementor | 3.34.4 | 3.35.4 | |
| 3 | Elementor Pro | 3.34.4 | 3.35.1 | |
| 4 | Embed Optimizer | 1.0.0-beta3 | - | |
| 5 | Enhanced Responsive Images | 1.7.0 | - | |
| 6 | Frontend Reset Password | 1.3.1 | 1.3.3 | |
| 7 | Git Updater | 12.22.0 | - | |
| 8 | GP Premium | 2.5.5 | - | Inactive |
| 9 | Gravity Forms | 2.9.26 | 2.9.27 | |
| 10 | Gravity Forms + Custom Post Types | 3.1.29 | - | |
| 11 | Gravity Forms ActiveCampaign Add-On | 2.2.0 | - | |
| 12 | Gravity Forms All Fields Template | 0.9.3 | - | |
| 13 | Gravity Forms Survey Add-On | 4.2.1 | - | |
| 14 | Gravity Forms User Registration Add-On | 5.4.0 | - | |
| 15 | Gravity PDF | 6.14.1 | - | |
| 16 | Imagify | 2.2.7 | - | |
| 17 | Index WP MySQL For Speed | 1.5.6 | - | |
| 18 | LD - Quiz Customization Question Bank | 2.1.0 | - | **Custom code** (WisdmLabs) |
| 19 | LearnDash LMS | 4.25.8.1 | 5.0.1 | **MAJOR VERSION** |
| 20 | LearnDash LMS - Certificate Builder | 1.1.4 | - | |
| 21 | LearnDash LMS - Elementor | 1.0.11 | - | |
| 22 | LearnDash LMS - GravityForms Integration | 2.1.3 | - | |
| 23 | LightStart | 2.6.20 | - | |
| 24 | LoginPress | 6.1.2 | - | |
| 25 | LoginPress Pro | 6.1.2 | - | |
| 26 | Modern Image Formats | 2.6.1 | - | |
| 27 | NinjaFirewall (WP Edition) | 4.8.3 | - | |
| 28 | NinjaScanner | 3.2.8 | - | |
| 29 | OttoKit | 1.1.20 | - | |
| 30 | PNG to JPG | 4.5 | - | |
| 31 | Reusable Content & Text Blocks by Loomisoft | 1.4.3 | - | |
| 32 | SnapOrbital Notes for LearnDash | 1.8 | - | |
| 33 | Speculative Loading | 1.6.0 | - | |
| 34 | Stream | 4.1.1 | - | |
| 35 | Sucuri Security | 2.6 | - | |
| 36 | Uncanny Toolkit for LearnDash | 3.8.0.2 | - | |
| 37 | Uncanny Toolkit Pro for LearnDash | 4.4 | - | |
| 38 | Wisdmlabs Quiz button Customization | 1.0.0 | - | **Custom code** (WisdmLabs) |
| 39 | WP Mail SMTP | 4.7.1 | - | |
| 40 | WP Rocket | 3.20.3 | - | Inactive |
| 41 | WP Rocket - Change Remove Unused CSS Parameters | - | - | Inactive |
| 42 | WPFront User Role Editor | 4.2.4 | - | |

**Updates currently available (6):** Code Snippets 3.9.5, Elementor 3.35.4, Elementor Pro 3.35.1, Frontend Reset Password 1.3.3, Gravity Forms 2.9.27, LearnDash LMS 5.0.1 (MAJOR)

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)

---

*Last updated: 2026-02-11*
