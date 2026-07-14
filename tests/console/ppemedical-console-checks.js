/**
 * PPE Medical -- ppemedical.com browser console regression checks
 * Site profile: WooCommerce + dual Authorize.Net gateways + WooCommerce Subscriptions (Risk: HIGH)
 *
 * WHAT IT TESTS
 *   - Visible WooCommerce errors on the page (a rendered .woocommerce-error = broken flow)
 *   - Stylesheets  : did any CSS 404?
 *   - Shop            : product cards render
 *   - Product          : price + Add to Cart button + express checkout buttons (Stripe / PayPal) render
 *   - Cart             : cart renders (items or a proper empty-cart message)
 *   - Checkout         : payment gateways render (Authorize.Net present) + Place Order button present
 *   - Account          : My Account renders (login form or dashboard)
 *
 * HOW TO RUN
 *   Test in an INCOGNITO window (fresh, logged-out) so you see the site as a real customer -- a
 *   logged-in/admin session and cached state can hide problems. Open one of the test URLs below,
 *   then paste this file into DevTools > Console.
 *
 * TEST URLS (ppemedical.com)
 *   Product : https://ppemedical.com/product/2-day-clinical-skills-and-procedure-cme-workshop-september-orlando-florida-2/
 *             (verified: Add to Cart + Stripe express checkout + PayPal render here)
 *   Cart    : https://ppemedical.com/cart/
 *   Checkout: https://ppemedical.com/checkout/   (add an item to the cart first, or it redirects)
 *   Account : https://ppemedical.com/my-account/
 *   Shop    : a product archive / category page (confirm the store's archive slug; a WooCommerce
 *             default of https://ppemedical.com/shop/ may or may not be enabled on this site)
 *
 * READ-ONLY: it inspects the page only. It does NOT add to cart, place an order, or submit payment.
 * Express checkout buttons render inside cross-origin Stripe/PayPal iframes, so this snippet confirms
 * they RENDERED but cannot click them -- click each express button manually (incognito) to confirm it
 * opens the correct checkout. Do the actual test purchase manually per the checklist.
 */
(() => {
  const results = [];
  const add = (check, status, detail) => results.push({ check, status, detail });
  const bodyCls = document.body.className || '';
  const is = (t) => bodyCls.includes(t);

  // --- page type (WooCommerce body classes) ---
  let pageType = 'other';
  if (is('single-product')) pageType = 'product';
  else if (is('woocommerce-cart')) pageType = 'cart';
  else if (is('woocommerce-checkout')) pageType = 'checkout';
  else if (is('woocommerce-account')) pageType = 'account';
  else if (is('post-type-archive-product') || is('woocommerce-shop') || document.querySelector('ul.products')) pageType = 'shop';
  add('Page type', 'INFO', pageType + '  (' + location.pathname + ')');

  // --- visible WooCommerce error notice ---
  const wcError = document.querySelector('.woocommerce-error');
  if (wcError) add('WooCommerce notice', 'FAIL', 'A .woocommerce-error is rendered: ' + (wcError.innerText || '').trim().slice(0, 160));

  // --- stylesheet / asset loads ---
  const res = performance.getEntriesByType('resource');
  const cssOnly = res.filter((r) => r.name.split('?')[0].toLowerCase().endsWith('.css'));
  const failed = cssOnly.filter((r) => r.responseStatus && r.responseStatus >= 400);
  add('Stylesheets', failed.length ? 'FAIL' : 'PASS',
    failed.length
      ? failed.length + ' CSS returned >=400: ' + failed.map((r) => r.name.split('/').pop() + '=' + r.responseStatus).join(', ')
      : cssOnly.length + ' CSS loaded, 0 failed. (Cross-origin files report status 0 and are skipped.)');

  // --- shop / archive ---
  if (pageType === 'shop') {
    const products = document.querySelectorAll('ul.products li.product, .wc-block-grid__product, .wp-block-woocommerce-product-template li').length;
    add('Shop products', products > 0 ? 'PASS' : 'FAIL', products + ' product cards rendered.');
  }

  // --- single product ---
  if (pageType === 'product') {
    const addToCart = document.querySelector('.single_add_to_cart_button, form.cart button[type="submit"]');
    const price = document.querySelector('.summary .price, p.price, .woocommerce-Price-amount');
    add('Product Add to Cart', addToCart ? 'PASS' : 'FAIL', addToCart ? 'Add to Cart button present.' : 'No Add to Cart button found -- product may not be purchasable.');
    add('Product price', price ? 'PASS' : 'WARN', price ? 'Price rendered: ' + (price.innerText || '').trim() : 'No price element found.');

    // Express checkout (Stripe Payment Request / Apple Pay / Google Pay / Link, plus PayPal).
    // These render inside CROSS-ORIGIN iframes, so we can only detect that the button area
    // rendered -- not click it or see inside it. Whether a wallet is actually offered depends
    // on the browser/device (Apple Pay in Safari, Google Pay in Chrome with a saved card).
    const stripeWrap = document.querySelector('#wc-stripe-express-checkout-element, .wc-stripe-express-checkout-element, #wc-stripe-payment-request-button, .wc-stripe-payment-request-wrapper, .wc-stripe-payment-request-button');
    const stripeFrames = document.querySelectorAll('iframe[title="Secure express checkout frame"]').length;
    const paypalFrames = document.querySelectorAll('iframe[title*="PayPal" i], .paypal-buttons, [id^="ppcp"], [id*="paypal-button"]').length;
    if (stripeFrames > 0 || paypalFrames > 0) {
      add('Express checkout', 'PASS',
        'Rendered: ' + stripeFrames + ' Stripe express frame(s)' + (paypalFrames > 0 ? ' + PayPal' : '') +
        '. This confirms the buttons rendered only -- CLICK each in an incognito window to confirm it opens the correct checkout (wallet availability is browser/device dependent).');
    } else if (stripeWrap) {
      add('Express checkout', 'WARN', 'Stripe express-checkout container is present but no button iframe rendered -- likely a wallet-unavailable browser, or the Stripe plugin failed to initialize. Retry on a device with Apple Pay / Google Pay.');
    } else {
      add('Express checkout', 'WARN', 'No express checkout (Stripe / PayPal) buttons detected. If this product should offer express checkout, investigate the Stripe plugin.');
    }
  }

  // --- cart ---
  if (pageType === 'cart') {
    const cartForm = document.querySelector('.woocommerce-cart-form, .cart_totals, .wc-block-cart');
    const emptyCart = document.querySelector('.cart-empty, .wc-empty-cart-message, .wc-block-cart__empty-cart');
    if (cartForm) add('Cart render', 'PASS', 'Cart contents/totals rendered.');
    else if (emptyCart) add('Cart render', 'PASS', 'Cart is empty but the empty-cart page rendered correctly.');
    else add('Cart render', 'FAIL', 'Neither cart contents nor an empty-cart message rendered -- cart page is broken.');
  }

  // --- checkout : payment gateways (the HIGH-risk surface) ---
  if (pageType === 'checkout') {
    const paymentBox = document.querySelector('#payment, .wc-block-checkout__payment-method, .woocommerce-checkout-payment');
    const gateways = Array.from(document.querySelectorAll('.wc_payment_methods input[name="payment_method"], .wc-block-components-radio-control__input'));
    const placeOrder = document.querySelector('#place_order, .wc-block-components-checkout-place-order-button');
    if (!paymentBox) {
      add('Checkout payment', 'FAIL', 'No payment section rendered -- customers cannot pay.');
    } else if (gateways.length === 0) {
      add('Checkout payment', 'FAIL', 'Payment section present but NO payment gateways rendered -- payment is down.');
    } else {
      const ids = gateways.map((g) => g.value || g.id).filter(Boolean);
      const hasAuthNet = ids.some((i) => /auth|net|accept/i.test(i));
      add('Checkout gateways', hasAuthNet ? 'PASS' : 'WARN',
        gateways.length + ' gateway(s): ' + ids.join(', ') + (hasAuthNet ? '' : ' -- verify an Authorize.Net gateway is present.'));
    }
    add('Checkout Place Order', placeOrder ? 'PASS' : 'FAIL', placeOrder ? 'Place Order button present (not clicked).' : 'No Place Order button found.');
  }

  // --- account ---
  if (pageType === 'account') {
    const acct = document.querySelector('.woocommerce-MyAccount-content, .woocommerce-MyAccount-navigation, form.woocommerce-form-login, .u-column1');
    add('My Account render', acct ? 'PASS' : 'FAIL', acct ? 'My Account (login form or dashboard) rendered.' : 'My Account did not render.');
  }

  // --- summary ---
  const n = (s) => results.filter((r) => r.status === s).length;
  console.group('%cPPE ppemedical.com console check -- ' + location.hostname, 'font-weight:bold;font-size:13px');
  console.table(results);
  console.log('Summary: %c' + n('FAIL') + ' FAIL', 'color:#c00;font-weight:bold', '/', n('WARN') + ' WARN', '/', n('PASS') + ' PASS');
  console.log('%cReminder: this only confirms the UI rendered. Run a real test-mode checkout manually per the checklist.', 'color:#a60');
  console.groupEnd();
  return results;
})();
