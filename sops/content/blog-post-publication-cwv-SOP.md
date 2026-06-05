# SOP: Blog Post Publication with Core Web Vitals & SEO Verification

**Version:** 0.3
**Date:** 2026-05-06
**Status:** Active
**Last updated:** 2026-06-04
**Last reviewed by:** Juan Sanchez (QA), Technical Lead
**Applies to:** Content Creator (anyone authoring blog posts), Maintenance Technician, Technical Lead
**Purpose:** Publish blog posts on ppemedical.com without regressing Core Web Vitals (LCP, CLS, INP) and with Yoast SEO meta correctly set, verified with lab tests and field data inside the 28-day CrUX window.

**SEO stack (verified 2026-05-06):** Yoast SEO Premium. IndexNow enabled (publish notifies Bing/Yandex instantly; do not click Publish until QA-ready). XML sitemap enabled. Schema defaults: Article / WebPage. Default social image not set, so each post must supply its own OG image.

**Related ticket:** OST #937446
**Past incidents:** #565057 (Blog CWV failures), #420047 (Desktop CLS), #459901 (GSC fail / PSI pass), #154223 (GSC CLS), #943410 (Mobile LCP)

---

## Prerequisites

✅ Author or editor access to ppemedical.com WordPress admin
✅ Gorilla Core Web Vitals Monitor plugin active (Settings > Core Web Vitals)
✅ Chrome or Edge with DevTools
✅ ~15 minutes blocked off after publishing for QA (Steps 6-8). QA runs immediately, not next day.

---

## What is This SOP?

PPE Medical blog posts have repeatedly regressed Core Web Vitals after publication, sometimes silently for weeks until GSC's 28-day CrUX window catches up. This SOP gives the content creator a deterministic publish-then-QA process: the post goes live, QA runs within 15 minutes, and a regression triggers a revert before indexing matters. Kinsta staging is not used for QA because staging response times do not match production.

---

## Feedback & Support

If anything in this SOP is wrong, missing, ambiguous, or breaks while you are following it, **email support@gorilladevops.com** with:

- The step number you were on
- A screenshot of what you saw
- The post URL (if already published)

We will reply with a workaround for the immediate post and update the SOP so the next person does not hit the same issue. No question is too small; the goal is for any Content Creator to publish confidently without guessing.

---

## Roles & Responsibilities

### Content Creator
Any team member authoring a blog post on ppemedical.com. No developer or SEO-specialist background is assumed.
- Decides whether the post needs an above-the-fold image (default: no)
- Prepares images per Step 2; sets Yoast SEO meta per Step 4
- Runs the full publication workflow on every post
- Monitors field data and indexing on Days 1, 3, 7

### Maintenance Technician
- Spot-checks the most recent 3 posts each monthly cycle via the Gorilla CWV Monitor logs
- Escalates regressions to the Technical Lead

### Technical Lead
- Owns the Gorilla CWV Monitor configuration and the global CSS/Perfmatters stack
- Investigates regressions originating from theme, plugin, or template (not post content)

---

## Process Workflow

### Step 1 - Decide Whether the Post Needs an Above-the-Fold Image

**Default: no image above the fold.** It is the largest source of LCP regressions on this site. Text LCP renders in under 1s; image LCP routinely lands 2.0s-8.0s.

Use one only if **all** are true:

- The image is editorially required (a chest X-ray for an X-ray post; a stock stethoscope is not)
- It cannot be moved further down without losing meaning
- You will follow every image rule in Step 2

**Outcome:** Yes/no decision recorded in post draft notes.

---

### Step 2 - Prepare Images

**Format:** WebP only. Convert JPEG/PNG locally with GIMP (`File > Export As`) or `cwebp` (`brew install webp`; `cwebp -q 80 in.jpg -o out.webp`). No AVIF, JPEG, or PNG uploads. Quality 75-82 for photos; 90 or lossless for X-rays, diagrams, charts.

**Size:** 200 KB max per image. Hard ceiling: never close to 1 MB. If lossless WebP exceeds 200 KB, downscale dimensions.

**Dimensions:** Resize source to 1024 px wide max before upload. Every `<img>` must render with explicit `width` and `height` (Gutenberg adds them; verify in DevTools).

**Above-the-fold image only:**

- Must be the WordPress featured image (Perfmatters keys off it)
- Perfmatters auto-adds `fetchpriority="high"` and `<link rel="preload" as="image">`. Verify both in View Source after publish; if missing, escalate to Technical Lead.
- Kinsta CDN delivers WebP; Imagify is the secondary path. Upload WebP; the CDN handles the rest.

**PSI image audits:** Image-savings flags are guidance, not a gate. Recompress only if PSI suggests >30 KB savings. The Performance score and LCP/CLS/INP numbers in Step 6 are the gate.

**Outcome:** All images WebP, ≤1024 px, ≤200 KB, with explicit dimensions.

---

### Step 3 - Author the Post

- Use core Gutenberg or GenerateBlocks. Both are safe (GenerateBlocks CSS already loads on this site).
- **Never use Elementor on blog posts.** Caused header reflow CLS in #565057 and loads stylesheets the blog template otherwise omits.
- Do not embed Elementor sync patterns (also caused CLS in #565057). Local block patterns are fine.
- Descriptive `alt` on every image; empty alt only for purely decorative images.
- Tables: core/table block. Avoid plugin table libraries (late CSS injection causes CLS).
- Keep the intro paragraph to 1-2 sentences so text LCP renders fast on mobile.

**Outcome:** Draft uses approved blocks and has alt text everywhere.

---

### Step 4 - Configure Yoast SEO Meta

Set in the Yoast sidebar before publishing. IndexNow notifies Bing/Yandex the moment Publish is clicked, so meta must be final at that point.

**SEO tab (Yoast snippet preview must be green or amber on every field, never red):**

- **Focus keyphrase:** one phrase, not already used as the focus keyphrase on another post (Yoast Premium will warn on cannibalization). Confirm green or amber, never red.
- **SEO title:** ≤60 characters; keyphrase near the start; site name appended via the template (default).
- **Slug:** short, lowercase-with-hyphens, contains the keyphrase, no stop words, no dates. Set this before the first publish; if it must change after publish, use **WP Admin > SEO > Redirects** (Yoast Premium) to add a 301.
- **Meta description:** 120-156 characters (Yoast turns the bar red above 156). Include the keyphrase, write as a benefit sentence. Do not leave Yoast to auto-generate from content for medical posts.
- **Cornerstone content:** toggle on for pillar/long-form posts that should rank for broad terms.
- **Advanced > Allow search engines to show this post:** Yes (default). Confirm before publish.

**AI-assisted drafting (allowed, with guardrails):**

- It is acceptable to use an AI assistant (Claude, ChatGPT, etc.) to draft candidate values for the focus keyphrase, SEO title, slug, and meta description. Prompt it with the post's H1, intro paragraph, and target audience; ask for 3-5 candidates per field within the length limits above.
- Paste each candidate into the Yoast sidebar and accept only ones that produce a green or amber light. AI counts characters loosely, so re-check Yoast's bar.
- **For medical posts:** AI must not invent or paraphrase clinical claims. Treat AI output as a starting structure; verify every clinical term against the post body before publishing. If a claim is not in the post body, it does not belong in the meta description.

**Social tab:**

- **Featured image vs. social image conflict (important):** the blog template renders the featured image above the fold, making it the LCP element. If Step 1 says no above-the-fold image, **do not set a featured image**. Instead, upload a 1200x630 image in Yoast's **Social > Facebook image** so Open Graph cards still render. Twitter inherits unless overridden.
- If Step 1 says yes (above-the-fold image is editorially required), the featured image doubles as the OG image; confirm it is at least 1200x630 and crops correctly in the OG preview.

**Schema tab:**

- Page type: **Web Page** (default). Article type: **Article** (default). Override to **Medical Web Page** only if the post is clinical reference content and the Technical Lead has approved.

**Internal links (Yoast Premium suggestions):**

- Add 2-3 internal links to related published posts using the Premium suggestion box. This both helps E-E-A-T and updates the Yoast text-link counter.

**Outcome:** Yoast traffic light is green or amber on both readability and SEO; OG image is set; slug is final.

---

### Step 5 - Publish, Then Run QA Immediately

WordPress preview URLs require an authenticated session, so PSI cannot test them. Kinsta staging response times do not match production. The practical path: publish, then run Steps 6-8 within 15 minutes. **Yoast IndexNow fires on publish**, so the URL is sent to search engines immediately; QA must follow without delay.

1. Click **Publish**. Note the publication time.
2. Copy the live URL.
3. Run Steps 6, 7, 8 in sequence. Do not walk away.
4. If any check fails, **Edit > Switch to draft**, fix, re-publish, re-test. A 15-minute live-then-reverted post is not meaningfully indexed; Yoast will re-ping IndexNow on re-publish.

---

### Step 6 - Lab Test on the Live URL (PSI)

1. Open https://pagespeed.web.dev/, paste the live URL.
2. Test mobile first, desktop second.
3. Record:
   - Performance: 90+
   - LCP: <2.5s (stretch <2.0s)
   - CLS: <0.1 (target 0.00-0.05)
   - INP: <200ms
4. "Avoid large layout shifts" listing any element from this post's body is a hard fail.

If any target misses: revert, fix, re-publish, re-run.

---

### Step 7 - Throttled DevTools Simulation

PSI uses fixed throttling. This step catches issues PSI misses (#459901: "fails in GSC but not in PSI").

1. Open the live URL in Chrome > DevTools.
2. **Network** tab: throttling = **Slow 4G**.
3. **Performance** tab: CPU = **4x slowdown**.
4. Hard reload (Cmd+Shift+R).
5. **Lighthouse** tab: Mobile audit, "Simulated throttling".
6. Lighthouse LCP/CLS/INP should be within 30% of PSI. Larger divergence = inconsistent loading; investigate.

---

### Step 8 - Field Data Debug

Confirm Gorilla CWV Monitor records metrics for this post.

1. Open `https://ppemedical.com/blog/your-new-post/?web_vitals_debug=1`.
   **Note:** the parameter is `?web_vitals_debug=1`, not `?debug=1` (original ticket misnamed it).
2. DevTools > Console.
3. Scroll, click, wait 5+ seconds.
4. Console must show CLS, LCP, INP events with `metric_rating: good` and a `debug_target` selector.
5. If any rating is `poor` or `needs-improvement`: note `debug_target`, trace to the block, revert, fix, re-test.

---

### Step 9 - Monitor Field Data and Indexing for 28 Days

CrUX is a 28-day rolling window, so field data lags lab data. SEO indexing is also delayed despite IndexNow.

**Content Creator:**
- **Day 1:** Re-run PSI mobile (within 10% of Step 6; investigate drift). In Google Search Console > URL Inspection, paste the new URL and click **Request Indexing**. Confirm the OG card preview at https://www.opengraph.xyz/ (renders the card as Facebook, LinkedIn, Slack, and X see it).
- **Day 3:** WP admin > Settings > Core Web Vitals > Logs. Filter `page_path` for the new URL. Expect zero/near-zero "poor" entries. In GSC, confirm "URL is on Google".
- **Day 7:** Re-check Logs. Confirm the post is appearing in `https://ppemedical.com/sitemap_index.xml` (Yoast post sitemap). Any "poor" CWV entries: note `metric_name` + `debug_target` and escalate.

**Maintenance Technician (Days 14-28):**
- During the monthly cycle, query the logs for the most recent 3 posts.
- More than 5 "poor" entries in 28 days: flag for review.
- Cross-check GSC > Core Web Vitals (new posts not in "poor"/"needs improvement") and GSC > Pages (new posts indexed, no "Discovered - currently not indexed" status).

---

## Common Mistakes

| Mistake | Why It Hurts | Avoid |
|---------|--------------|-------|
| 3000+ px JPEG, let WP resize | Image >500 KB, LCP regresses | 1024 px WebP locally, then upload |
| AVIF as upload source | Site delivers WebP via CDN; AVIF is wasted | WebP only |
| Featured image because "every post needs one" | Image becomes LCP, 2-4x slower than text | Default to no above-the-fold image; use Yoast Social image instead |
| Elementor on blog posts | Header reflow CLS in #565057 | Gutenberg or GenerateBlocks |
| Skipping Step 7 because PSI passed | #459901: GSC failed, PSI passed | Always run Step 7 |
| Publish then walk away | IndexNow already pinged search engines; field data captures regressions fast | Run Steps 6-8 within 15 minutes |
| Skipping Day 1/3/7 monitoring | 28-day CrUX hides regressions | Follow Step 9 |
| Plugin table blocks | Late CSS injection causes CLS | core/table block |
| `<img>` without width/height | Browser cannot reserve space, CLS | Verify in rendered HTML |
| Reusing a focus keyphrase from another post | Yoast cannibalization warning; both pages compete | Pick a unique keyphrase per post |
| Letting Yoast auto-generate the meta description | Generic, often truncated, weakens CTR on medical SERPs | Hand-write or AI-draft 120-156 chars with the keyphrase, confirm Yoast bar is green |
| Pasting AI output into Yoast without checking | Character count drifts; AI may invent clinical claims not in the post | Verify Yoast green light + verify every clinical term exists in post body |
| Changing the slug after publish without redirect | Old URL 404s; backlinks and IndexNow ping go stale | Yoast Premium > Tools > Redirects; add 301 |
| No featured image and no Yoast social image | OG card on Facebook/LinkedIn renders blank | Set Yoast Social > Facebook image (1200x630) |
| Featured image below 1200x630 | OG cards crop badly on Twitter/Facebook | Use 1200x630 source for the social image |

---

## Publication Checklist

### Before Publish

**Content & images:**
- [ ] Above-the-fold image is editorially required (or none used)
- [ ] All images WebP, ≤1024 px, ≤200 KB, with alt text
- [ ] Body uses Gutenberg or GenerateBlocks (no Elementor, no Elementor sync patterns)
- [ ] Tables use core/table
- [ ] Intro paragraph is 1-2 sentences

**Yoast SEO meta:**
- [ ] Focus keyphrase set, not duplicated from another post (no cannibalization warning)
- [ ] SEO title ≤60 chars, keyphrase near the start
- [ ] Slug short, lowercase-hyphens, contains keyphrase, no stop words
- [ ] Meta description 120-156 chars (Yoast bar green), includes keyphrase, no AI-invented clinical claims
- [ ] Cornerstone toggle set correctly
- [ ] Allow search engines to show this post = Yes
- [ ] Schema: Web Page + Article (or approved override)
- [ ] Featured image set OR Yoast Social > Facebook image set (1200x630)
- [ ] 2-3 internal links added from Yoast Premium suggestions

### Within 15 Minutes of Publish

- [ ] PSI Mobile: Performance ≥90, LCP <2.5s, CLS <0.1, INP <200ms
- [ ] No "Avoid large layout shifts" entry from this post
- [ ] All `<img>` have explicit width/height in rendered HTML
- [ ] Lighthouse Slow 4G + 4x CPU: LCP/CLS/INP green, within 30% of PSI
- [ ] `?web_vitals_debug=1` console shows CLS, LCP, INP all "good"
- [ ] View Source: OG tags (`og:title`, `og:description`, `og:image`) and Article schema JSON-LD present
- [ ] PSI numbers and publish time recorded in post notes

**If above-the-fold image was used:**
- [ ] View Source: `fetchpriority="high"` on the image
- [ ] View Source: `<link rel="preload" as="image">` in `<head>`

**If any check fails:** revert to draft, fix, re-publish, re-run.

---

## Verification Checklist (Day 1 onward)

- [ ] Day 1: PSI within 10% of Step 6 numbers
- [ ] Day 1: GSC URL Inspection > Request Indexing submitted; OG card preview verified
- [ ] Day 3: Gorilla CWV Logs zero "poor" entries for the new URL
- [ ] Day 3: GSC reports "URL is on Google"
- [ ] Day 7: CWV logs still zero/near-zero; post present in `sitemap_index.xml`
- [ ] Day 14: GSC Core Web Vitals not regressed; post not stuck in "Discovered - currently not indexed"
- [ ] Day 28: Post in GSC "good URLs" (CWV) and "Indexed" (Pages), or not yet counted

---

## Escalation

Escalate to the Technical Lead with the post URL and screenshots if:

- PSI mobile still fails after image rules are applied (likely theme or plugin)
- Lighthouse diverges >30% from PSI (inconsistent loading)
- CWV logs show "poor" with `debug_target` outside post content (header, footer, third-party)
- GSC reports a regression that does not match lab results
- GSC URL Inspection shows the post is blocked, noindexed, or stuck in "Discovered - currently not indexed" past Day 14
- Google Rich Results Test (https://search.google.com/test/rich-results) or https://validator.schema.org/ reports errors on the live URL

If you are not sure whether something qualifies as an escalation, **email support@gorilladevops.com first**. It is better to send a low-stakes question than to publish a regression and fix it later.

---

## Related Documents

- [Staged Website Updates SOP](../maintenance/staged-website-updates-SOP.md)
- [Visual Regression Testing SOP](../maintenance/visual-regression-testing-SOP.md)
- [Regression Test Checklist: ppemedical.com](../../checklists/regression-test-ppemedical-com.md)
- Gorilla CWV Monitor plugin readme (in `gorilla-cwv-monitor` repo)
- Yoast SEO documentation: https://yoast.com/help/
- Google Search Console: https://search.google.com/search-console
- Schema validators: https://validator.schema.org/ and https://search.google.com/test/rich-results
- OST #937446 (source request); OST #565057 (canonical incident)

---

## Open Questions for Review

1. Is 200 KB the right per-image budget, or tighten to 150 KB for non-critical images?
2. Should Step 7 (throttled DevTools) be optional for text-only posts?
3. Does Day 1/3/7 monitoring fit the Content Creator's workload, or should the Maintenance Technician own it from Day 1?
4. Should the Publication Checklist live as a separate file in `checklists/`?
5. Resolved: ppemedical.com only. ppetoolkit.com does not have the Gorilla CWV Monitor plugin and is the product-access site, not a blog.
6. Yoast `disable-author = true` removes author from schema. For medical content E-E-A-T, should we re-enable author archives and add an author bio block? (Site-wide SEO question, not per-post.)
7. Should the Maintenance Technician keep Yoast SEO Premium patched in the monthly cycle?

---

**Document Owner:** Technical Lead
**Next review:** After the first end-to-end run-through by a Content Creator, or 2026-07-01 (whichever first)

---

*This is a living document. Update when conventions change.*
