#!/usr/bin/env bash
# =============================================================================
# update-ppemedical.sh -- WP-CLI update & regression checks for ppemedical.com
#
# Risk level: High
# Strategy:   Core first, non-WooCommerce plugins, then WooCommerce in order
# Usage:      SSH into Kinsta environment, then: bash update-ppemedical.sh
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }
print_pass()    { echo -e "  ${GREEN}[PASS]${NC} $1"; }
print_fail()    { echo -e "  ${RED}[FAIL]${NC} $1"; FAILURES=$((FAILURES + 1)); }
print_warn()    { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
print_info()    { echo -e "  ${BLUE}[INFO]${NC} $1"; }

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------
FAILURES=0
WARNINGS=0

# ---------------------------------------------------------------------------
# Verify WP-CLI is available
# ---------------------------------------------------------------------------
if ! command -v wp &> /dev/null; then
    echo -e "${RED}ERROR: WP-CLI is not installed or not in PATH.${NC}"
    exit 1
fi

# ---------------------------------------------------------------------------
# Detect environment
# ---------------------------------------------------------------------------
print_header "Environment Detection"

SITE_URL=$(wp option get siteurl 2>/dev/null || echo "")
if [[ -z "$SITE_URL" ]]; then
    echo -e "${RED}ERROR: Could not detect site URL. Are you in the WordPress root directory?${NC}"
    echo "Try: cd ~/public"
    exit 1
fi

print_info "Site URL: $SITE_URL"

if echo "$SITE_URL" | grep -qi "staging"; then
    print_info "Environment: STAGING"
else
    echo ""
    echo -e "${YELLOW}  ************************************************************${NC}"
    echo -e "${YELLOW}  *  WARNING: This appears to be PRODUCTION                  *${NC}"
    echo -e "${YELLOW}  *  Make sure you have a manual backup before proceeding.    *${NC}"
    echo -e "${YELLOW}  ************************************************************${NC}"
    echo ""
    read -r -p "  Continue on production? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# ---------------------------------------------------------------------------
# Pre-update snapshot
# ---------------------------------------------------------------------------
print_header "Pre-Update Snapshot"

WP_VERSION_BEFORE=$(wp core version)
ACTIVE_PLUGIN_COUNT_BEFORE=$(wp plugin list --status=active --format=count)
ERROR_LOG="/www/kinsta/logs/error.log"

print_info "WordPress version: $WP_VERSION_BEFORE"
print_info "Active plugins: $ACTIVE_PLUGIN_COUNT_BEFORE"

if [[ -f "$ERROR_LOG" ]]; then
    ERROR_COUNT_BEFORE=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
    print_info "PHP Fatal errors in log (before): $ERROR_COUNT_BEFORE"
else
    ERROR_COUNT_BEFORE=0
    print_warn "Error log not found at $ERROR_LOG -- skipping error log checks"
fi

echo ""
print_info "Current plugin versions:"
wp plugin list --status=active --format=table

# ---------------------------------------------------------------------------
# Check available updates
# ---------------------------------------------------------------------------
print_header "Available Updates"

CORE_UPDATE=$(wp core check-update --format=count 2>/dev/null || echo "0")
PLUGIN_UPDATES=$(wp plugin list --update=available --format=count 2>/dev/null || echo "0")

print_info "Core updates available: $CORE_UPDATE"
print_info "Plugin updates available: $PLUGIN_UPDATES"

if [[ "$CORE_UPDATE" == "0" && "$PLUGIN_UPDATES" == "0" ]]; then
    print_info "No updates available. Nothing to do."
    exit 0
fi

echo ""
if [[ "$PLUGIN_UPDATES" != "0" ]]; then
    wp plugin list --update=available --format=table
fi

echo ""
read -r -p "  Proceed with updates? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# ---------------------------------------------------------------------------
# Update WordPress core
# ---------------------------------------------------------------------------
print_header "Updating WordPress Core"

if [[ "$CORE_UPDATE" != "0" ]]; then
    wp core update
    wp core update-db
    print_pass "WordPress core updated"
else
    print_info "Core already up to date"
fi

# ---------------------------------------------------------------------------
# Update non-WooCommerce plugins first
# ---------------------------------------------------------------------------
print_header "Updating Non-WooCommerce Plugins"

# These are plugins that are NOT part of the WooCommerce ecosystem.
# We update them first so any WooCommerce-related issues are isolated.
NON_WOO_PLUGINS=(
    "elementor"
    "elementor-pro"
    "wordpress-seo"
    "wordpress-seo-premium"
    "microsoft-clarity"
    "ottokit"
    "frontend-reset-password"
    "ninjafirewall"
    "ninjascanner"
    "sucuri-scanner"
    "wp-mail-smtp-pro"
    "perfmatters"
    "imagify"
    "cloudflare"
    "redirection"
    "stream"
    "generateblocks"
    "gp-premium"
    "gtm4wp"
    "index-wp-mysql-for-speed"
    "wp-2fa"
    "code-snippets"
    "wpfront-user-role-editor"
    "simple-cloudflare-turnstile"
    "git-updater"
)

NON_WOO_UPDATED=0
for plugin in "${NON_WOO_PLUGINS[@]}"; do
    # Check if this plugin has an update available
    if wp plugin list --name="$plugin" --update=available --format=count 2>/dev/null | grep -q "1"; then
        print_info "Updating $plugin..."
        if wp plugin update "$plugin" 2>/dev/null; then
            print_pass "$plugin updated"
            NON_WOO_UPDATED=$((NON_WOO_UPDATED + 1))
        else
            print_fail "$plugin update failed"
        fi
    fi
done

if [[ "$NON_WOO_UPDATED" -eq 0 ]]; then
    print_info "No non-WooCommerce plugin updates to apply"
else
    print_info "$NON_WOO_UPDATED non-WooCommerce plugin(s) updated"
fi

# ---------------------------------------------------------------------------
# Update WooCommerce ecosystem in order
# ---------------------------------------------------------------------------
print_header "Updating WooCommerce Ecosystem"

echo -e "  ${YELLOW}Updating WooCommerce plugins in the correct order:${NC}"
echo -e "  ${YELLOW}  1. WooCommerce core${NC}"
echo -e "  ${YELLOW}  2. WooCommerce Subscriptions${NC}"
echo -e "  ${YELLOW}  3. Other WooCommerce extensions${NC}"
echo ""

# Step 1: WooCommerce core
if wp plugin list --name="woocommerce" --update=available --format=count 2>/dev/null | grep -q "1"; then
    print_info "Updating WooCommerce core..."
    if wp plugin update woocommerce 2>/dev/null; then
        print_pass "WooCommerce core updated"
    else
        print_fail "WooCommerce core update failed"
    fi
else
    print_info "WooCommerce core already up to date"
fi

# Step 2: WooCommerce Subscriptions
if wp plugin list --name="woocommerce-subscriptions" --update=available --format=count 2>/dev/null | grep -q "1"; then
    print_info "Updating WooCommerce Subscriptions..."
    if wp plugin update woocommerce-subscriptions 2>/dev/null; then
        print_pass "WooCommerce Subscriptions updated"
    else
        print_fail "WooCommerce Subscriptions update failed"
    fi
else
    print_info "WooCommerce Subscriptions already up to date"
fi

# Step 3: Other WooCommerce extensions
WOO_EXTENSIONS=(
    "woocommerce-gateway-authorize-net-cim"
    "woocommerce-gateway-authorize-net-enterprise"
    "woocommerce-min-max-quantities"
    "woocommerce-product-addons"
    "woocommerce-product-dependencies"
    "woocommerce-checkout-field-editor"
    "checkout-field-editor-for-woocommerce"
    "woocommerce-customer-order-coupon-export"
    "wc-variations-radio-buttons"
    "cart-abandonment-recovery"
    "woocommerce-subscriptions-custom-price-string"
    "safercheckout-lite"
    "woocommerce-com-update-manager"
    "ignitewoo-updater"
)

WOO_EXT_UPDATED=0
for plugin in "${WOO_EXTENSIONS[@]}"; do
    if wp plugin list --name="$plugin" --update=available --format=count 2>/dev/null | grep -q "1"; then
        print_info "Updating $plugin..."
        if wp plugin update "$plugin" 2>/dev/null; then
            print_pass "$plugin updated"
            WOO_EXT_UPDATED=$((WOO_EXT_UPDATED + 1))
        else
            print_fail "$plugin update failed"
        fi
    fi
done

if [[ "$WOO_EXT_UPDATED" -eq 0 ]]; then
    print_info "No WooCommerce extension updates to apply"
fi

# ---------------------------------------------------------------------------
# Catch any remaining plugin updates
# ---------------------------------------------------------------------------
print_header "Checking for Remaining Updates"

REMAINING=$(wp plugin list --update=available --format=count 2>/dev/null || echo "0")
if [[ "$REMAINING" != "0" ]]; then
    print_info "$REMAINING plugin(s) still have updates available:"
    wp plugin list --update=available --format=table
    echo ""
    read -r -p "  Update remaining plugins? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        wp plugin update --all
        print_pass "Remaining plugins updated"
    else
        print_warn "Skipped $REMAINING remaining update(s)"
    fi
else
    print_info "All plugins are up to date"
fi

# ---------------------------------------------------------------------------
# Clear caches
# ---------------------------------------------------------------------------
print_header "Clearing Caches"

wp cache flush 2>/dev/null && print_pass "Object cache flushed" || print_warn "Cache flush returned non-zero (may be OK if no object cache)"

# ---------------------------------------------------------------------------
# Post-update checks
# ---------------------------------------------------------------------------
print_header "Post-Update Checks"

WP_VERSION_AFTER=$(wp core version)
ACTIVE_PLUGIN_COUNT_AFTER=$(wp plugin list --status=active --format=count)

print_info "WordPress version: $WP_VERSION_BEFORE -> $WP_VERSION_AFTER"
print_info "Active plugins: $ACTIVE_PLUGIN_COUNT_BEFORE -> $ACTIVE_PLUGIN_COUNT_AFTER"

if [[ "$ACTIVE_PLUGIN_COUNT_AFTER" -lt "$ACTIVE_PLUGIN_COUNT_BEFORE" ]]; then
    print_fail "Active plugin count DECREASED -- a plugin may have been deactivated"
else
    print_pass "Active plugin count unchanged or increased"
fi

# Critical plugins still active
print_header "Critical Plugin Checks"

CRITICAL_PLUGINS=(
    "woocommerce"
    "woocommerce-gateway-authorize-net-cim"
    "woocommerce-subscriptions"
    "elementor"
    "elementor-pro"
    "wp-mail-smtp-pro"
    "ninjafirewall"
)

for plugin in "${CRITICAL_PLUGINS[@]}"; do
    if wp plugin is-active "$plugin" 2>/dev/null; then
        print_pass "$plugin is active"
    else
        if wp plugin list --name="$plugin" --format=count 2>/dev/null | grep -q "1"; then
            print_fail "$plugin is INSTALLED but NOT ACTIVE"
        else
            print_warn "$plugin not found (slug may differ -- verify manually)"
        fi
    fi
done

# Key page HTTP checks
print_header "Key Page HTTP Checks"

KEY_PAGES=(
    "/"
    "/shop/"
    "/cart/"
    "/checkout/"
    "/my-account/"
)

for page in "${KEY_PAGES[@]}"; do
    url="${SITE_URL}${page}"
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" 2>/dev/null || echo "000")
    if [[ "$http_code" == "200" ]]; then
        print_pass "$page returned HTTP $http_code"
    elif [[ "$http_code" == "000" ]]; then
        print_fail "$page -- connection failed (timeout or DNS error)"
    elif [[ "$http_code" =~ ^3[0-9][0-9]$ ]]; then
        print_warn "$page returned HTTP $http_code (redirect -- may be OK)"
    else
        print_fail "$page returned HTTP $http_code"
    fi
done

# Database check
print_header "Database Check"

if wp db check --quiet 2>/dev/null; then
    print_pass "Database integrity check passed"
else
    print_fail "Database integrity check reported issues"
fi

# Cron check
print_header "Cron Check"

CRON_COUNT=$(wp cron event list --format=count 2>/dev/null || echo "0")
if [[ "$CRON_COUNT" -gt "0" ]]; then
    print_pass "WP-Cron has $CRON_COUNT scheduled events"
else
    print_warn "No cron events found (unusual)"
fi

# Error log check
print_header "Error Log Check"

if [[ -f "$ERROR_LOG" ]]; then
    ERROR_COUNT_AFTER=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
    NEW_ERRORS=$((ERROR_COUNT_AFTER - ERROR_COUNT_BEFORE))
    if [[ "$NEW_ERRORS" -le 0 ]]; then
        print_pass "No new PHP Fatal errors in log"
    else
        print_fail "$NEW_ERRORS new PHP Fatal error(s) detected in log"
        echo ""
        echo -e "  ${YELLOW}Recent fatal errors:${NC}"
        grep "PHP Fatal" "$ERROR_LOG" | tail -5
    fi
else
    print_warn "Error log not found -- skipping"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_header "Summary"

echo -e "  Site:       $SITE_URL"
echo -e "  WP Core:    $WP_VERSION_BEFORE -> $WP_VERSION_AFTER"
echo -e "  Plugins:    $ACTIVE_PLUGIN_COUNT_BEFORE active -> $ACTIVE_PLUGIN_COUNT_AFTER active"
echo ""

if [[ "$FAILURES" -eq 0 && "$WARNINGS" -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}ALL CHECKS PASSED${NC}"
elif [[ "$FAILURES" -eq 0 ]]; then
    echo -e "  ${YELLOW}${BOLD}PASSED WITH $WARNINGS WARNING(S)${NC}"
else
    echo -e "  ${RED}${BOLD}$FAILURES CHECK(S) FAILED${NC} (plus $WARNINGS warning(s))"
    echo -e "  ${RED}Review failures above before proceeding.${NC}"
fi

# ---------------------------------------------------------------------------
# Manual testing reminders
# ---------------------------------------------------------------------------
print_header "Manual Testing Reminders"

echo -e "  The following items require browser testing:"
echo ""
echo -e "  ${YELLOW}[ ]${NC} Shop page displays products correctly"
echo -e "  ${YELLOW}[ ]${NC} Add to cart and cart page work"
echo -e "  ${YELLOW}[ ]${NC} Checkout flow completes (credit card fields, place order)"
echo -e "  ${YELLOW}[ ]${NC} Payment processing works (Authorize.Net)"
echo -e "  ${YELLOW}[ ]${NC} Order confirmation page and email received"
echo -e "  ${YELLOW}[ ]${NC} Subscription products display and sign-up works"
echo -e "  ${YELLOW}[ ]${NC} My Account page loads for logged-in users"
echo -e "  ${YELLOW}[ ]${NC} No JavaScript console errors on key pages"
echo -e "  ${YELLOW}[ ]${NC} Mobile responsive layout displays correctly"
echo ""
echo -e "  Full checklist: checklists/regression-test-ppemedical-com.md"
echo ""
