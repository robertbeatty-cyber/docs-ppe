/**
 * PPE Medical -- ppetoolkit.com browser console regression checks
 * Site profile: LearnDash LMS + custom QBank + Elementor-built course content (Risk: CRITICAL)
 *
 * WHAT IT TESTS
 *   - Session/role : are you a non-admin student? (admin sessions MASK the #218633 render bug)
 *   - Content render: is the topic/lesson body present, or blank? (the #218633 catcher)
 *   - Stylesheets  : did any Elementor CSS 404? (the 2026-07-07 asset symptom)
 *   - Debug leak   : leftover "template name :" template-engine echo
 *   - Quiz         : QBank quiz container + Start button custom text (read-only, never submits)
 *
 * HOW TO RUN
 *   1. In an INCOGNITO window, log in as the dedicated enrolled non-admin student
 *      (gd-qa-student -- see reference/test-accounts.md), NOT as an admin. Incognito + non-admin
 *      is essential: an admin session bypasses the cache and masks the #218633 render bug.
 *   2. Open one of the test URLs below (a course, a lesson, an Elementor-built topic, or a quiz).
 *   3. DevTools > Console. If prompted, type "allow pasting". Paste this whole file, press Enter.
 *
 * TEST URLS (ppetoolkit.com)
 *   Course : https://ppetoolkit.com/courses/live-lectures/
 *   Lesson : https://ppetoolkit.com/lessons/advanced-practice-provider-clinical-skills-and-procedure-workshop-1/
 *   Topic  : https://ppetoolkit.com/topic/cardiac-disorders/        (went blank on 07-07)
 *   Topic  : https://ppetoolkit.com/topic/pulmonary-disorders/
 *   Topic  : https://ppetoolkit.com/topic/cervical-spine-injuries/  (Elementor CSS file 404'd on 07-07)
 *   Quiz   : open a QBank quiz from inside the Live Lectures course (quiz slug varies).
 *
 * READ-ONLY: inspects the page and reports. It does not submit forms or start/submit quizzes.
 */
(() => {
  const results = [];
  const add = (check, status, detail) => results.push({ check, status, detail });
  const banner = (msg, bg) =>
    console.log('%c' + msg, 'background:' + bg + ';color:#fff;font-weight:bold;padding:3px 8px;border-radius:3px');
  const bodyCls = document.body.className || '';
  const is = (t) => bodyCls.includes(t);

  // --- page type (WordPress/LearnDash body classes) ---
  let pageType = 'other';
  if (is('single-sfwd-topic')) pageType = 'topic';
  else if (is('single-sfwd-lessons')) pageType = 'lesson';
  else if (is('single-sfwd-courses')) pageType = 'course';
  else if (is('single-sfwd-quiz')) pageType = 'quiz';
  add('Page type', 'INFO', pageType + '  (' + location.pathname + ')');

  // --- session / role context ---
  const loggedIn = document.body.classList.contains('logged-in');
  const editTools = !!document.querySelector(
    '#wp-admin-bar-edit, #wp-admin-bar-new_content, [id^="wp-admin-bar-edit_with_elementor"], .elementor-edit-link'
  );
  if (!loggedIn) {
    add('Session', 'WARN', 'Not logged in. Log in as the enrolled student before testing render.');
  } else if (editTools) {
    add('Session', 'WARN', 'Editor/admin tools present -- you may be testing as an admin, which MASKS the #218633 blank-content bug. Re-test as an enrolled non-admin student.');
  } else {
    add('Session', 'PASS', 'Logged in, no editor tools visible (looks like a non-admin session).');
  }

  // --- GUARD RAIL: this run does not validate #218633 unless you are a non-admin on a content page ---
  if (editTools || !loggedIn || pageType === 'other') {
    banner('THIS RUN PROVES NOTHING ABOUT #218633. Switch to LindeeAbe (enrolled student) and open a topic/lesson/quiz.', '#b00020');
  }

  // --- content render (topic / lesson) : the #218633 catcher ---
  if (pageType === 'topic' || pageType === 'lesson') {
    const root = document.querySelector('article, main, #content, .learndash-wrapper') || document.body;
    const text = (root.innerText || '').trim();
    const widgets = root.querySelectorAll('.elementor-widget').length;
    const media = root.querySelectorAll('img, video, iframe').length;
    const declaredElementor = !!document.querySelector('[data-elementor-type]');
    const detail = 'text=' + text.length + ' chars, elementorWidgets=' + widgets + ', media=' + media;
    if (text.length < 400 && widgets === 0 && media === 0) {
      add('Content render', 'FAIL', 'Content region is effectively empty -- matches the #218633 blank-content symptom. ' + detail);
    } else if (declaredElementor && widgets === 0) {
      add('Content render', 'WARN', 'Elementor layout is declared but zero rendered widgets were found. ' + detail);
    } else {
      add('Content render', 'PASS', detail);
    }
  }

  // --- stylesheet / asset loads (the 07-07 CSS-404 symptom) ---
  const res = performance.getEntriesByType('resource');
  const cssOnly = res.filter((r) => r.name.split('?')[0].toLowerCase().endsWith('.css'));
  const failed = cssOnly.filter((r) => r.responseStatus && r.responseStatus >= 400);
  const elementorCss = cssOnly.filter((r) => r.name.includes('/uploads/elementor/css/') || r.name.includes('custom-frontend'));
  if (failed.length) {
    add('Stylesheets', 'FAIL', failed.length + ' CSS returned >=400: ' + failed.map((r) => r.name.split('/').pop() + '=' + r.responseStatus).join(', '));
  } else if (document.querySelector('[data-elementor-type]') && elementorCss.length === 0) {
    add('Stylesheets', 'WARN', 'Elementor page but no Elementor CSS files loaded -- content may render unstyled/blank. ' + cssOnly.length + ' CSS total.');
  } else {
    add('Stylesheets', 'PASS', cssOnly.length + ' CSS loaded, 0 failed. Elementor CSS files: ' + elementorCss.length + '. (Cross-origin files report status 0 and are skipped.)');
  }

  // --- leftover template-engine debug echo ---
  if (/template name\s*:/.test(document.body.innerText || '')) {
    add('Debug leak', 'WARN', '"template name :" debug string is visible on the page -- leftover template-engine output. Report to have it disabled.');
  }

  // --- quiz presence (read-only; does NOT start/submit) ---
  if (pageType === 'quiz') {
    const quizBox = document.querySelector('.wpProQuiz_content, .learndash-wrapper .wpProQuiz_quiz');
    const startBtn = document.querySelector('input[name="startQuiz"], .wpProQuiz_button[name="startQuiz"], .wpProQuiz_button');
    add('Quiz render', quizBox ? 'PASS' : 'FAIL', quizBox ? 'Quiz container present.' : 'No quiz container (.wpProQuiz_content) found on a quiz page.');
    if (startBtn) add('Quiz start button', 'INFO', 'Button text: "' + (startBtn.value || startBtn.innerText || '').trim() + '" -- verify it matches the custom QBank text.');
    else add('Quiz start button', 'WARN', 'Start button not found (quiz may already be started, or uses custom markup).');
  }

  // --- summary ---
  const n = (s) => results.filter((r) => r.status === s).length;
  console.group('%cPPE ppetoolkit.com console check -- ' + location.hostname, 'font-weight:bold;font-size:13px');
  console.table(results);
  console.log('Summary: %c' + n('FAIL') + ' FAIL', 'color:#c00;font-weight:bold', '/', n('WARN') + ' WARN', '/', n('PASS') + ' PASS');
  console.groupEnd();
  return results;
})();
