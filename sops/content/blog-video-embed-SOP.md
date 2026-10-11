# SOP: Adding Videos to Blog Posts Without Slowing the Page

**Version:** 1.0
**Date:** 2026-10-11
**Status:** Active
**Last updated:** 2026-10-11
**Last reviewed by:** Technical Lead
**Applies to:** Content Creator (anyone adding a Vimeo or YouTube video to a blog post on ppemedical.com)
**Purpose:** Add Vimeo and YouTube videos to blog posts so they show a thumbnail with a play button and only load the video player when the reader clicks play.

**Requires:** child theme gp-ppemedical 3.15.100 or later (Appearance > Themes)

---

## Prerequisites

✅ Editor or administrator access to ppemedical.com WordPress admin
✅ The Vimeo or YouTube link of the video (e.g. `https://vimeo.com/291226743`)
✅ A private (incognito) browser window for the check in Step 4

---

## What is This SOP?

A video player from Vimeo or YouTube loads several hundred kilobytes of scripts as soon as the page opens, even when nobody plays the video. That slows the page down for every reader and lowers the PageSpeed score. Adding one CSS class to the video, `gd-lazy-video`, makes the site show a light thumbnail with a play button instead; the player only loads when the reader clicks play, and the video then starts straight away.

This is the only manual step. The thumbnail, its size and format, and the play button are handled automatically by the theme and the Perfmatters plugin.

---

## Feedback & Support

If anything in this SOP is wrong, unclear, or does not work as described, **email support@gorilladevops.com** with the step number, a screenshot, and the post URL.

---

## Roles & Responsibilities

### Content Creator
- Adds the `gd-lazy-video` class to every Vimeo or YouTube video in a blog post (Step 2)
- Checks the post in a private window after updating (Step 4)

### Technical Lead
- Maintains the video feature in the child theme (`docs/VIDEO-LAZY-LOAD.md` in the gp-ppemedical repo)
- Reviews it when Perfmatters is updated (an admin notice appears on the Dashboard)

---

## Process Workflow

### Step 1 - Add the Video with an Embed Block

New blog posts use the block editor.

1. In the post, click **+** (Add block) where the video should go.
2. Search for **Vimeo** (or **YouTube**) and select the block.
3. Paste the video link, e.g. `https://vimeo.com/291226743`, and click **Embed**.

**Outcome:** The video appears in the editor as a normal player. That is expected; the thumbnail only appears on the published page.

---

### Step 2 - Add the Class `gd-lazy-video`

1. Click the video block once so it is selected (a blue outline appears).
2. In the right sidebar, open the **Block** tab (not "Post").
3. Scroll down and open **Advanced**.
4. In **Additional CSS class(es)**, type exactly:
   ```
   gd-lazy-video
   ```
   If the field already contains a class, add a space and then `gd-lazy-video`.
5. Repeat for every video in the post.

**Outcome:** Each video block has `gd-lazy-video` in Additional CSS class(es).

---

### Step 3 - Publish or Update

1. Click **Publish** (new post) or **Update** (existing post).
2. Kinsta clears the page cache for this post automatically. If you still see the old version in Step 4 after 2 minutes, clear the cache from the Kinsta menu in the top admin bar (Clear Caches), or email support.

**Outcome:** The post is saved and live.

---

### Step 4 - Check the Post in a Private Window

You must check **logged out**. When you are logged in to WordPress, the site's speed optimisations are switched off, so you always see the normal player there.

1. Open a private/incognito window (Chrome: Cmd+Shift+N on Mac, Ctrl+Shift+N on Windows).
2. Open the post URL.
3. Check:
   - The video shows a **thumbnail with a play button**, not the Vimeo/YouTube player controls
   - Clicking the thumbnail **starts the video**
4. Run PageSpeed Insights on the post as described in the [Blog Post Publication SOP](blog-post-publication-cwv-SOP.md), Step 6.

**Outcome:** Thumbnail with play button visible logged out; video plays on click; PSI targets met.

---

### Older Posts in the Classic Editor

Some older posts (e.g. `/blog/subclavian-central-line/`) were written in the classic editor, where the video is an `<iframe>` code. Add the class to the iframe itself:

1. Edit the post and switch to the **Text** tab (top right of the editor).
2. Find the line that starts with `<iframe` and contains `vimeo` or `youtube`.
3. Add `class="gd-lazy-video"` right after `<iframe`:
   ```html
   <iframe class="gd-lazy-video" src="https://player.vimeo.com/video/291226743" width="640" height="360" frameborder="0" allowfullscreen></iframe>
   ```
   If the iframe already has `class="..."`, add `gd-lazy-video` inside the quotes, separated by a space.
4. Click **Update** and check as in Step 4.

The same works in a block editor **Custom HTML** block that contains an iframe.

---

## Common Mistakes & How to Avoid Them

| Mistake | What happens | Avoid |
|---------|--------------|-------|
| Checking while logged in | You see the normal player and think it did not work | Always check in a private window |
| Class in the **Post** tab or a typo (`gd-lazy-videos`, `gd_lazy_video`) | Video loads the full player again | Block tab > Advanced > Additional CSS class(es), exactly `gd-lazy-video` |
| Class added to a Group or Columns block around the video | Not picked up | Select the video block itself |
| Class on a video that must play automatically (background or hero video) | It waits for a click instead of autoplaying | Leave the class off videos that must autoplay |
| Pasting a bare Vimeo link on its own line in the classic editor | Cannot carry a class, loads the full player | Use the iframe code with the class, or the block editor Vimeo block |
| Video added with Elementor | Blog posts must not use Elementor (see Blog Post Publication SOP) | Use the block editor |

---

## Verification Checklist

- [ ] Every Vimeo/YouTube video in the post has `gd-lazy-video`
- [ ] Private window: each video shows a thumbnail with a play button
- [ ] Private window: clicking plays the video
- [ ] PSI mobile meets the Blog Post Publication SOP targets (LCP under 2.5 s)

**Escalate (email support@gorilladevops.com)** if the thumbnail is blank, the video does not play after clicking, or PSI LCP is worse than before adding the video.

---

## Related Documents

- [Blog Post Publication with CWV & SEO Verification SOP](blog-post-publication-cwv-SOP.md)
- Technical documentation: `docs/VIDEO-LAZY-LOAD.md` in the gp-ppemedical child theme repo
- [Regression Test Checklist: ppemedical.com](../../checklists/regression-test-ppemedical-com.md)

---

**Document Owner:** Technical Lead
**Next review:** After the first new blog post with a video, or 2027-01-11 (whichever first)

---

*This is a living document. Update when the editor or the video feature changes.*
