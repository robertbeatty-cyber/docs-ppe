# Regression Test Checklist: ppetoolkit.com

**Last updated:** 2026-10-29 (LearnDash updated to 5.2.2.1 and unpinned after user roles were given `read`, #218633)
**Last executed:** 2026-10-29 (staging, then production)
**Site:** https://ppetoolkit.com
**Staging:** https://staging.ppetoolkit.com
**Risk level:** Critical
**Total plugins:** 44 (37 active, 7 inactive), plus 6 must-use, verified on production 2026-10-29
**Key risk areas:** LearnDash LMS + custom QBank code; Elementor-rendered course content; user roles must keep the `read` capability (see incident 2026-07-07)

---

> **CRITICAL WARNING:** This site uses custom QBank code ("LD - Quiz Customization Question Bank" v2.1.0 by WisdmLabs) that deeply integrates with LearnDash. LearnDash major version updates can break quiz functionality. Always update LearnDash ALONE first, test QBank thoroughly, then proceed with other plugins. If QBank breaks, STOP and escalate to the Technical Lead immediately.

> **TEST AS A NON-ADMIN STUDENT -- NOT AS AN ADMIN (added 2026-07-07).** Every "renders correctly" / "displays correctly" check below **must** be verified while logged in as an **enrolled non-admin student**, in a separate browser or incognito window. Admin accounts bypass the page cache and trigger on-the-fly asset regeneration, so a page can look perfect to an admin while every student sees blank/broken content. The 2026-07-07 outage (ticket #218633) was a version of this: from LearnDash 5.1.5 on, users whose role lacks the `read` capability see blank topics/lessons, while admins see everything. Elementor's element cache had *masked* it for ~2 weeks until a cache clear exposed it. Testing solely as admin will miss this entire class of failure. **Also test with a user who is not a `student`** (for example `staff` + `author`, or `customer`); see [the finding](../reference/ppetoolkit-learndash-read-capability.md). Original incident write-up: `ansible-v2/docs/incidents/archive/2026-07/ppetoolkit-2026-07-07-learndash-outage-internal.md` (its "non-admin students" diagnosis is superseded by the finding).

> **AD-HOC & SECURITY UPDATES NEED THIS CHECKLIST TOO (added 2026-07-07).** The monthly staged-update cycle is not the only risk window. Any out-of-cycle change -- automated security updates, a single-plugin fix (e.g. OttoKit), or a vendor auto-update -- can break rendering. After **any** update to this site, run at minimum Section 0 (Cache & Asset Integrity) as a non-admin, not just the monthly batch.

> **LEARNDASH AND THE `read` CAPABILITY (updated 2026-10-29, ticket #218633).** From LearnDash 5.1.5 on, a user whose role lacks the WordPress `read` capability sees blank topics/lessons and "0/0 Steps", even with course access. That, not a general non-admin bug, is why content went blank in July, and why LearnDash was held at 5.1.4 until 2026-10-29. On 2026-10-29 `read` was added to the `staff`, `author`, `editor`, `contributor` and `customer` roles, LearnDash was updated to **5.2.2.1** on staging and production, and the Gorilla Essentials pin was removed. 5.2.2.1 closes CVE-2026-12843 and CVE-2026-12483, which affected 5.1.4. **Before and after any LearnDash update, confirm that every role which should see course content has `read`** (Section 8). `subscription_ended` and `free_tour` deliberately have no `read`, and users with no role get none; whether those users should keep access is waiting on the client. Full write-up, including how it was proven: [reference/ppetoolkit-learndash-read-capability.md](../reference/ppetoolkit-learndash-read-capability.md). Rollback: reinstall LearnDash **5.1.4** and pin it again (zip archived at Kinsta `private/plugin-holds/` and `ansible-v2/tmp/sfwd-lms-5.1.4.zip`, SHA256 `96c3ac2e9e21d1c479a30f5bbe967a0575258f5b5dc7be5949b738af0a05c537`).

---

## 0. Cache & Asset Integrity -- POST-UPDATE, VERIFY AS A NON-ADMIN (added 2026-07-07)

> Run this **first** after any update round. It is the cheapest catch for the 2026-07-07 failure mode (content intact, CSS/asset stale → blank for students, fine for admins).
>
> **Fast path:** while logged in as the enrolled student, paste the all-in-one snippet from [Browser Console Regression Checks](../guides/browser-console-regression-checks.md) into the Chrome console on a course, lesson, topic, and quiz page. It checks non-admin render, CSS 404s, session/role, and quiz presence in seconds, then step through the boxes below.

- [ ] After updates, clear **both** caches: WP Rocket (if active) **and** the Kinsta full-page cache (MyKinsta > Caching, or "Clear Caches" in the admin bar)
- [ ] In a separate/incognito browser, log in as an **enrolled non-admin student** (keep an admin session open in another browser to compare). Repeat the render checks as an enrolled **`staff` + `author`** or **`customer`** user
- [ ] Open a **course**, a **lesson**, AND a **topic** -- confirm the **body content and layout** render for the student (not just the sidebar/title bar)
- [ ] Specifically open an **Elementor-built topic** (e.g. `/topic/cardiac-disorders/`, `/topic/cervical-spine-injuries/`) -- these depend on generated Elementor CSS files
- [ ] Open DevTools > **Network** > filter **CSS** > hard-reload. Confirm **no stylesheet returns 404**. A 404 on an Elementor `post-<ID>.css` or `custom-frontend.min.css` means blank content for students.
- [ ] If a topic renders blank for the student but fine for the admin: **Elementor > Tools > Regenerate CSS & Data**, then clear both caches, retest as the student.
- [ ] Preventive: confirm **Elementor > Settings > Advanced > CSS Print Method**. `Internal Embedding` (inline CSS) is immune to this class of cache/asset-version mismatch; `External File` is faster but reintroduces the 07-07 risk on every cache purge.

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
- [ ] **SnapOrbital Notes:** Students can view and create notes on course/lesson pages, [learndash_my_notes] shortcode works. Still on 1.8: updates from 1.8 need a manual install (vendor notice)
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

> Course content on this site is Elementor-built. Verify these **as a non-admin student** (see Section 0) -- Elementor asset issues are admin-invisible.

- [ ] Pages built with Elementor render correctly on the frontend **for a non-admin student**
- [ ] No broken layouts or missing sections
- [ ] Elementor editor loads in admin (edit any page with Elementor)
- [ ] Dynamic content and widgets display correctly
- [ ] LearnDash-specific Elementor widgets (course/lesson/topic content) render correctly **for a non-admin student**
- [ ] Elementor CSS files are generating: no 404 on `post-<ID>.css` / `custom-frontend.min.css` in the Network tab (see Section 0)

---

## 8. User Authentication & Roles

- [ ] Student login works (test with a student test account)
- [ ] Student dashboard loads correctly after login
- [ ] Student sees only their enrolled courses
- [ ] Instructor/admin login works
- [ ] Role-based content restrictions function (e.g., enrolled-only content is gated)
- [ ] **Roles that should see course content have `read`** (`student`, `subscriber`, `group_leader`, `staff`, `author`, `editor`, `contributor`, `customer`). Over SSH: `wp eval 'foreach(wp_roles()->roles as $k=>$r) echo $k, "=", empty($r["capabilities"]["read"])?"NO":"read", "\n";'`. A missing `read` blanks LearnDash content for that role
- [ ] Logout works
- [ ] Frontend Reset Password: Frontend reset page loads and sends email
- [ ] **LoginPress / LoginPress Pro:** inactive on 2026-10-29 (whether to delete them is undecided); skip unless reactivated

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
- [ ] Gorilla Essentials: Tools > Gorilla Essentials loads; Site Hygiene shows email blocking on staging ("Outbound email is being blocked right now")
- [ ] PPE Content Blocks: content blocks render on pages that use them
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

**Captured from production 2026-10-29, after the October round**, via `wp plugin list --fields=name,title,status,version --format=csv`.

**Pending at capture:** only SnapOrbital Notes (see note). WordPress core 7.1.4, child theme `gp-ppetoolkit` 3.14.56 (parent GeneratePress 3.6.1).

| # | Plugin | Slug | Version | Notes |
|---|--------|------|---------|-------|
| 1 | Code Snippets | `code-snippets` | 4.0.0 |  |
| 2 | Elementor | `elementor` | 4.3.5 |  |
| 3 | Elementor Pro | `elementor-pro` | 4.3.2 |  |
| 4 | Embed Optimizer | `embed-optimizer` | 1.0.0-beta6 |  |
| 5 | Enhanced Responsive Images | `auto-sizes` | 1.8.0 |  |
| 6 | Frontend Reset Password | `frontend-reset-password` | 1.3.3 |  |
| 7 | Git Updater | `git-updater` | 14.4.3 |  |
| 8 | Gorilla Essentials | `gorilla-essentials` | 0.3.17 |  |
| 9 | Gravity Forms | `gravityforms` | 3.2.1 |  |
| 10 | Gravity Forms + Custom Post Types | `gravity-forms-custom-post-types` | 3.1.33 |  |
| 11 | Gravity Forms ActiveCampaign Add-On | `gravityformsactivecampaign` | 2.2.0 |  |
| 12 | Gravity Forms All Fields Template | `gw-gravity-forms-all-fields-template` | 0.9.3 |  |
| 13 | Gravity Forms Survey Add-On | `gravityformssurvey` | 4.2.3 |  |
| 14 | Gravity Forms User Registration Add-On | `gravityformsuserregistration` | 5.5.2 |  |
| 15 | Gravity PDF | `gravity-pdf` | 6.18.0 |  |
| 16 | Imagify | `imagify` | 2.3.4 |  |
| 17 | Index WP MySQL For Speed | `index-wp-mysql-for-speed` | 1.6.0 |  |
| 18 | LD - Quiz Customization Question Bank | `wisdmlabs-quiz-customization-question-bank` | 2.1.0 | **Custom code** (WisdmLabs) |
| 19 | LearnDash LMS | `sfwd-lms` | 5.2.2.1 | Updated from 5.1.4 on 2026-10-29 after roles got `read`. No longer pinned |
| 20 | LearnDash LMS - Certificate Builder | `learndash-certificate-builder` | 1.1.5 |  |
| 21 | LearnDash LMS - Elementor | `learndash-elementor` | 1.0.12 |  |
| 22 | LearnDash LMS - GravityForms Integration | `learndash-gravity-forms` | 2.1.3 |  |
| 23 | Modern Image Formats | `webp-uploads` | 2.7.1 |  |
| 24 | NinjaFirewall (WP Edition) | `ninjafirewall` | 4.9.2 |  |
| 25 | OttoKit | `suretriggers` | 1.1.42 |  |
| 26 | PNG to JPG | `png-to-jpg` | 4.6 |  |
| 27 | PPE Content Blocks | `ppe-content-blocks` | 1.1.2 |  |
| 28 | Safe SVG | `safe-svg` | 2.5.2 |  |
| 29 | SnapOrbital Notes for LearnDash | `snaporbital-notes-for-learndash` | 1.8 | 2.0.9 available but cannot auto-update: vendor says updates from 1.8 and below need a manual install (https://docs.snaporbital.com/support/) |
| 30 | Speculative Loading | `speculation-rules` | 1.7.0 |  |
| 31 | Stream - Activity Log & Audit Trail | `stream` | 4.4.0 |  |
| 32 | Sucuri Security - Auditing, Malware Scanner and Hardening | `sucuri-scanner` | 2.8.1 |  |
| 33 | Uncanny Toolkit for LearnDash | `uncanny-learndash-toolkit` | 3.8.2 |  |
| 34 | Uncanny Toolkit Pro for LearnDash | `uncanny-toolkit-pro` | 4.4.2 |  |
| 35 | Wisdmlabs Quiz button  Customization | `wdm_quiz_button_custom` | 1.0.0 | **Custom code** (WisdmLabs) |
| 36 | WP Mail SMTP | `wp-mail-smtp` | 4.10.3 |  |
| 37 | WPFront User Role Editor | `wpfront-user-role-editor` | 4.2.5 |  |

### Inactive (installed, not active)

| Plugin | Slug | Version |
|--------|------|---------|
| GP Premium | `gp-premium` | 2.5.5 |
| LoginPress | `loginpress` | 6.2.5 |
| LoginPress Pro | `loginpress-pro` | 6.2.3 |
| NinjaScanner | `ninjascanner` | 3.3.1 |
| Reusable Content & Text Blocks by Loomisoft | `loomisoft-content-blocks` | 1.4.3 |
| WP Rocket | `wp-rocket` | 3.20.3 |
| WP Rocket | Change Remove Unused CSS Parameters | `wp-rocket-rucss-change-parameters` | - |

### Must-use

| Plugin | Slug | Version |
|--------|------|---------|
| Activity Log Plugin | `activity-log-plugin` | 1.0.0 |
| Code Profiler (mu-plugin) | `0----code-profiler` | 1.0 |
| Index WP MySQL For Speed Upgrade Filter for mu-plugins. | `index-wp-mysql-for-speed-update-filter` | 1.6.0 |
| Kinsta Must-use Plugins | `kinsta-mu-plugins` | 3.6.1 |
| LearnDash LMS Multisite | `learndash-multisite` | 1.0.0 |
| NinjaFirewall WP (mu-plugin) | `0-ninjafirewall` | 1.0 |

---

## Related Documents

- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing Guide](../guides/visual-regression-testing-guide.md)
- [ppetoolkit.com: Blank Content and the `read` Capability](../reference/ppetoolkit-learndash-read-capability.md)

---

*Last updated: 2026-10-29 (LearnDash 5.2.2.1 after the `read` role fix; plugin table refreshed from production)*
