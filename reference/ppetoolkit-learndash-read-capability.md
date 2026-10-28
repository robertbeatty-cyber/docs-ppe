# ppetoolkit.com: Blank Course Content and the `read` Capability

**Last updated:** 2026-10-29
**Site:** https://ppetoolkit.com
**Related ticket:** #218633 (2026-07-07 blank course content)
**Status:** Cause proven 2026-10-29. Roles fixed and LearnDash 5.2.2.1 live on staging and production 2026-10-29. Client decision pending on users without a role or with `subscription_ended` / `free_tour` (see "Who is affected").

---

## Summary

Lessons and topics showed up blank for some logged-in members (July 2026, and again on staging in October). This was not a LearnDash defect that hits all non-admin users, which is how it was described in July. It depends on one WordPress capability, **`read`**:

- Users whose roles include `read` (`student`, `subscriber`, `group_leader`, administrators) see course content normally.
- Users whose roles do **not** include `read` see a blank topic or lesson body, and the course progress bar reads **"0/0 Steps"**, even though LearnDash reports they have access to the course.

On this site the `author`, `staff`, `editor`, `contributor` and `customer` roles had `read` removed at some point; standard WordPress roles all include it. It was added back to those five roles on 2026-10-29 (see the role change log).

LearnDash 5.1.4 shows content to these users anyway. From 5.1.5 on (production jumped from 5.1.4 to 5.1.6, so it surfaced with 5.1.6), LearnDash withholds content from users without `read`. The July outage was therefore the first LearnDash version that enforces `read` running on a site whose roles lack it. Updating LearnDash was safe only once those roles had `read` again, which was done on 2026-10-29.

---

## Symptom

- The topic or lesson title and the course outline in the sidebar render, but the body is empty.
- The course progress bar shows "0/0 Steps" (a working page shows, for example, "0/14 Steps").
- Admins see the page normally. So do students with the `student` role.
- In the page source, LearnDash's block is an empty wrapper: `<div class="learndash ... user_has_access" id="learndash_post_<id>"><div class="learndash-wrapper ..."></div></div>`.

---

## How it was proven (2026-10-29, staging, LearnDash 5.2.2.1)

1. **Student account:** `test_user123` with the `student` role. Topics in "Skills and Procedure Workshop Live Lectures" (course 9659) render fully.
2. **Same account, roles changed** to `staff` + `author`, then `author` only, `staff` only and `editor` only. Every topic renders blank with "0/0 Steps".
3. **Same account set back to `student`:** content returns.
4. **Server-side render** of four Elementor-built topics and one lesson: identical output for `student` and administrator. Empty output for a `staff` + `author` user.
5. **Capability comparison:** the only capability that `student` and `administrator` share and that `staff`, `author` and `editor` all lack is `read`.
6. **Direct test:** the same `staff` + `author` user, given `read` for one render (in memory, no database change), sees full content on every topic tested. Without `read`, the same topics are empty.
7. **Production comparison (2026-10-29):** `staff` and `author` users see content on production (LearnDash 5.1.4) although they lack `read`. The role definitions on production and staging are byte-identical (all 15 roles). The only differences between the environments are LearnDash (5.1.4 vs 5.2.2.1) and Gorilla Essentials (0.1.4 vs 0.3.17), and Gorilla Essentials does not touch course content.

### The exact code change

LearnDash **5.1.5** added a structural visibility check to `Step::is_content_visible()` (`src/Core/Models/Step.php`):

```php
if ( $course && ! $this->is_visible( $user ) ) {
    $is_content_visible = false;
}
```

`Step::is_visible()` (new, `@since 5.1.5`) passes the step and all its parent steps to `Step_Visibility::filter()` (new file `src/Core/Models/Steps/Step_Visibility.php`, `@since 5.1.5`). For any logged-in non-admin user, that keeps only the steps where `user_can( $user_id, 'read_post', $step_id )`. For a published post, WordPress maps `read_post` to the plain `read` capability. A user without `read` therefore fails for every step, so the content is hidden and the step count is 0.

In 5.1.4 the same `read_post` filter existed (`Has_Steps::filter_by_visibility()`), but it was opt-in: it ran only when a caller had set `limit_steps_visibility_to_user()`, and `is_content_visible()` did not use it.

The change arrived in 5.1.5, not 5.1.6. Production went from 5.1.4 straight to 5.1.6 in June 2026, which is why July pointed at 5.1.6. LearnDash exposes the result through the filter `learndash_model_{post_type}_is_content_visible`, but restoring `read` to the roles is the cleaner fix.

---

## Who is affected

Counted on production on 2026-10-29, **before the role fix**: users **without `read`** who have access to at least one of the 54 paid (closed) courses.

| Role(s) | Users |
|---------|-------|
| customer | 64 |
| staff (alone or with author, contributor or customer) | 41 |
| no role | 29 |
| subscription_ended | 24 |
| free_tour | 1 |
| **Total** | **159** |

After the role fix, the `customer` and `staff` users see content again. **54 users still have paid-course access but no `read`**: 24 `subscription_ended`, 1 `free_tour` and 29 with no role. They saw content on LearnDash 5.1.4 and do not on 5.2.2.1. Whether any of them should keep access is waiting on the client. Users with no role cannot be given `read` by changing a role; they would need a role assigned.

---

## Why the update matters now

LearnDash 5.1.4 is affected by two published vulnerabilities:

| CVE | Issue | Fixed in | Relevance here |
|-----|-------|----------|----------------|
| CVE-2026-12843 | Enrollment into paid courses through a REST endpoint without payment (4.25.0 to 5.1.6) | 5.1.6.1 | **Relevant:** 54 of 73 courses are paid (closed) |
| CVE-2026-12483 | Logged-in user can upload arbitrary files through assignment uploads | 5.1.5.1 | Not exploitable while no lesson or topic has assignment uploads enabled (0 on 2026-10-29) |

No LearnDash changelog entry from 5.1.6 to 5.2.2.1 mentions this behaviour, so do not expect a later version to change it.

---

## Plan

1. **On staging:** add `read` to the `staff`, `author`, `editor`, `contributor` and `customer` roles (Users > Roles via WPFront User Role Editor). Done 2026-10-29, see the change log below.
2. **Check on staging:** topics and lessons render for a user in each of those roles (real step counts, not "0/0"), and QBank and quizzes still work. **Done 2026-10-29.** Not done: blocking wp-admin for these roles (see the note under the change log).
3. **Client decision pending:** the 24 `subscription_ended` users, the 1 `free_tour` user and the 29 users with no role, all with paid-course access.
4. **On production,** in the monthly update window: apply the same role change first, then update LearnDash, then disable the LearnDash pin in Tools > Gorilla Essentials > Plugin Locks. **Done 2026-10-29** (the pin was removed when Gorilla Essentials was reinstalled at 0.3.17, and not re-added).
5. **After the production update:** test as a `staff` + `author` user and as a `customer`, not only as a `student`. **Done 2026-10-29:** an enrolled `student`, a `staff` + `author` user and a `customer` all see full content on production. A user with no role still gets a blank page, as expected.

### Role change log

**2026-10-29, staging then production** (LearnDash 5.2.2.1). Made in WPFront User Role Editor by the maintenance technician, who chose the capabilities per role. All changes below are intended. Applied to production on 2026-10-29; production `read` verified on all five roles.

| Role | Capabilities added |
|------|-------------------------------|
| `staff` | `read` |
| `customer` | `read` |
| `contributor` | `read` |
| `editor` | `read`, `edit_dashboard` |
| `author` | `read`, `create_courses`, `edit_courses`, `read_others_courses`, `create_posts`, `create_pages`, `read_others_posts`, `read_others_pages` |

Note: with these changes, `author` users (9 on production, 2026-10-29) can create and edit LearnDash courses.

**Open, waiting on the client:** `subscription_ended` and `free_tour` were not changed and still lack `read`. See "Who is affected" for the users concerned.

Not done: a wp-admin block for non-admin roles. With `read`, users in the roles above can open wp-admin (dashboard and profile). Nothing on the site blocks it; Uncanny Toolkit's "Hide Admin Bar" only hides the toolbar.

Rollback: reinstall LearnDash 5.1.4 (archived zip and checksum are in the [ppetoolkit.com checklist](../checklists/regression-test-ppetoolkit-com.md)) and pin it again. The roles can keep `read`, because 5.1.4 does not check it.

---

## Testing lesson

A `student` test account passes even when this bug is present, because `student` has `read`. Regression tests for ppetoolkit.com must therefore include at least one enrolled user who is not a `student` (for example `staff` + `author`, or `customer`), so that a role losing `read` again is caught. The [console check](../tests/console/ppetoolkit-console-checks.js) flags a blank LearnDash content block and a "0/0 Steps" progress bar.

---

## Related Documents

- [Regression Test Checklist: ppetoolkit.com](../checklists/regression-test-ppetoolkit-com.md)
- [Staged Website Updates SOP](../sops/maintenance/staged-website-updates-SOP.md) (Pinning a Plugin Version)
- [Test Accounts](test-accounts.md)
- [Browser Console Regression Checks](../guides/browser-console-regression-checks.md)
