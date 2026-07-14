/**
 * PPE Medical -- ppemedevents.com browser console regression checks
 * Site profile: The Events Calendar (Risk: STANDARD, 11 plugins -- simplest site)
 *
 * WHAT IT TESTS
 *   - Stylesheets   : did any CSS 404? (incl. The Events Calendar CSS)
 *   - Events listing : the calendar/list view renders event cards
 *   - Single event   : title + date/time (schedule) + venue block render
 *   - Calendar view  : month grid renders (when on the month view)
 *
 * HOW TO RUN
 *   Test in an INCOGNITO window (fresh, logged-out) so you see the site as a real visitor.
 *   Open one of the test URLs below, then paste this file into DevTools > Console.
 *   Login is not required (events are public).
 *
 * TEST URLS (ppemedevents.com) -- The Events Calendar default routes; confirm the base slug on the site:
 *   Events (calendar) : https://ppemedevents.com/events/
 *   List view         : https://ppemedevents.com/events/list/
 *   Month view        : https://ppemedevents.com/events/month/
 *   Single event      : open any event from the calendar (URL like https://ppemedevents.com/event/<slug>/)
 *
 * READ-ONLY: it inspects the page only. It does not register for events or submit anything.
 */
(() => {
  const results = [];
  const add = (check, status, detail) => results.push({ check, status, detail });
  const bodyCls = document.body.className || '';
  const is = (t) => bodyCls.includes(t);

  // --- page type (The Events Calendar body classes) ---
  let pageType = 'other';
  if (is('single-tribe_events')) pageType = 'event';
  else if (is('post-type-archive-tribe_events') || is('tribe-events-page') || is('events-archive') || document.querySelector('.tribe-events')) pageType = 'events';
  add('Page type', 'INFO', pageType + '  (' + location.pathname + ')');

  // --- stylesheet / asset loads ---
  const res = performance.getEntriesByType('resource');
  const cssOnly = res.filter((r) => r.name.split('?')[0].toLowerCase().endsWith('.css'));
  const failed = cssOnly.filter((r) => r.responseStatus && r.responseStatus >= 400);
  const tribeCss = cssOnly.filter((r) => r.name.includes('the-events-calendar') || r.name.includes('/tribe') || r.name.includes('tribe-common'));
  if (failed.length) {
    add('Stylesheets', 'FAIL', failed.length + ' CSS returned >=400: ' + failed.map((r) => r.name.split('/').pop() + '=' + r.responseStatus).join(', '));
  } else if (document.querySelector('.tribe-events') && tribeCss.length === 0) {
    add('Stylesheets', 'WARN', 'Events page but no Events Calendar CSS loaded -- views may render unstyled. ' + cssOnly.length + ' CSS total.');
  } else {
    add('Stylesheets', 'PASS', cssOnly.length + ' CSS loaded, 0 failed. Events Calendar CSS files: ' + tribeCss.length + '.');
  }

  // --- events listing / calendar ---
  if (pageType === 'events') {
    const container = document.querySelector('.tribe-events, #tribe-events, .tribe-common');
    if (!container) {
      add('Events view', 'FAIL', 'No Events Calendar container (.tribe-events) rendered on an events page.');
    } else {
      const cards = document.querySelectorAll(
        '.tribe-events-calendar-list__event, .tribe-events-calendar-month__calendar-event, .tribe-events-calendar-day__event'
      ).length;
      const monthDays = document.querySelectorAll('.tribe-events-calendar-month__day').length;
      if (cards > 0) add('Events view', 'PASS', cards + ' event(s) rendered in the current view.');
      else if (monthDays > 0) add('Events view', 'PASS', 'Month grid rendered (' + monthDays + ' day cells); no events in the visible range.');
      else add('Events view', 'WARN', 'Events container rendered but no event cards or month grid found -- confirm there are upcoming events, or the view may be broken.');
    }
  }

  // --- single event ---
  if (pageType === 'event') {
    const title = document.querySelector('.tribe-events-single-event-title, h1.tribe-events-title, .tribe-events-content h1, h1.entry-title');
    const schedule = document.querySelector('.tribe-events-schedule, .tribe-events-single-section .tribe-events-abbr, .tribe-block__event-datetime');
    const venue = document.querySelector('.tribe-events-meta-group-venue, .tribe-block__venue, .tribe-events-venue-details, .tribe-events-single-section.tribe-events-event-meta');
    add('Event title', title ? 'PASS' : 'FAIL', title ? 'Title: ' + (title.innerText || '').trim().slice(0, 80) : 'No event title rendered.');
    add('Event schedule', schedule ? 'PASS' : 'WARN', schedule ? 'Date/time block rendered: ' + (schedule.innerText || '').trim().slice(0, 80) : 'No date/time (schedule) block found.');
    add('Event venue', venue ? 'PASS' : 'WARN', venue ? 'Venue/meta block rendered.' : 'No venue/meta block found (may be an online or venue-less event).');
  }

  // --- summary ---
  const n = (s) => results.filter((r) => r.status === s).length;
  console.group('%cPPE ppemedevents.com console check -- ' + location.hostname, 'font-weight:bold;font-size:13px');
  console.table(results);
  console.log('Summary: %c' + n('FAIL') + ' FAIL', 'color:#c00;font-weight:bold', '/', n('WARN') + ' WARN', '/', n('PASS') + ' PASS');
  console.groupEnd();
  return results;
})();
